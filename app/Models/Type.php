<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Type extends Model
{
    public function watches()
    {
        return $this->hasMany(Watch::class);
    }
}
