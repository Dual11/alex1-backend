<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Feature extends Model
{
    public function watches()
    {
        return $this->belongsToMany(Watch::class);
    }
}
