<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
{
    // Skip if column already removed
    if (! Schema::hasColumn('documents', 'department_id')) {
        return;
    }

    if (DB::getDriverName() === 'sqlite') {

        // 🔥 ADD THIS: ensure clean state
        DB::statement('PRAGMA foreign_keys = OFF;');

        $this->rebuildDocumentsTableWithoutDepartmentId();

        DB::statement('PRAGMA foreign_keys = ON;');

        return;
    }

    Schema::table('documents', function (Blueprint $table) {
        $table->dropForeign(['department_id']);
        $table->dropColumn('department_id');
    });
}


    public function down(): void
    {
        if (Schema::hasColumn('documents', 'department_id')) {
            return;
        }

        Schema::table('documents', function (Blueprint $table) {
            $table->foreignId('department_id')
                ->nullable()
                ->constrained('departments')
                ->after('amount');

            $table->index('department_id');
            $table->index(['department_id', 'status']);
            $table->index('department_id', 'documents_department_perf_index');
        });
    }

    private function rebuildDocumentsTableWithoutDepartmentId(): void
    {
        Schema::disableForeignKeyConstraints();

        Schema::create('documents_tmp', function (Blueprint $table) {
            $table->id();
            $table->date('date');
            $table->foreignId('encoded_by_id')->constrained('users');
            $table->string('type_of_document');
            $table->string('document_code')->unique();
            $table->string('document_number')->nullable()->unique();
            $table->string('pay_claimant');
            $table->text('particular');
            $table->decimal('amount', 15, 2);
            $table->foreignId('routed_department_id')->nullable()->constrained('departments');
            $table->string('status')->default('Pending');
            $table->text('remarks')->nullable();
            $table->date('date_out')->nullable();
            $table->timestamps();
            $table->softDeletes();
            $table->timestamp('inactive_alerted_at')->nullable();
            $table->timestamp('inactive_read_at')->nullable();
            $table->text('inactive_reason')->nullable();
        });

        DB::statement(<<<'SQL'
            INSERT INTO documents_tmp (
                id,
                date,
                encoded_by_id,
                type_of_document,
                document_code,
                document_number,
                pay_claimant,
                particular,
                amount,
                routed_department_id,
                status,
                remarks,
                date_out,
                created_at,
                updated_at,
                deleted_at,
                inactive_alerted_at,
                inactive_read_at,
                inactive_reason
            )
            SELECT
                id,
                date,
                encoded_by_id,
                type_of_document,
                document_code,
                document_number,
                pay_claimant,
                particular,
                amount,
                routed_department_id,
                status,
                remarks,
                date_out,
                created_at,
                updated_at,
                deleted_at,
                inactive_alerted_at,
                inactive_read_at,
                inactive_reason
            FROM documents
        SQL);

        Schema::drop('documents');
        Schema::rename('documents_tmp', 'documents');

        DB::statement('CREATE INDEX IF NOT EXISTS documents_encoded_by_id_index ON documents (encoded_by_id)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_status_index ON documents (status)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_date_index ON documents (date)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_type_of_document_index ON documents (type_of_document)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_encoded_by_id_date_index ON documents (encoded_by_id, date)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_status_perf_index ON documents (status)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_encoded_by_perf_index ON documents (encoded_by_id)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_date_perf_index ON documents (date)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_created_at_perf_index ON documents (created_at)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_encoded_status_updated_perf_index ON documents (encoded_by_id, status, updated_at)');
        DB::statement('CREATE INDEX IF NOT EXISTS documents_routed_department_perf_index ON documents (routed_department_id)');

        Schema::enableForeignKeyConstraints();
    }
};
