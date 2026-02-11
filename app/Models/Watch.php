<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Watch extends Model
{
    public function type() {
        return $this->belongsTo(Type::class);
    }
    public function strap() {
        return $this->belongsTo(Strap::class);
    }
    public function features() {
        return $this->belongsToMany(Feature::class);
    }

    protected $fillable = ['brand', 'model', 'type_id', 'strap_id', 'price', 'description'];
}
