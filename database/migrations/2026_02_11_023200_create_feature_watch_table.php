<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('feature_watch', function (Blueprint $table) {
            $table->foreignId('watch_id')
                ->constrained('watches')           // ← explícito
                ->onDelete('cascade');

            $table->foreignId('feature_id')
                ->constrained('features')          // ← explícito
                ->onDelete('cascade');

            $table->primary(['watch_id', 'feature_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('feature_watch');
    }
};
