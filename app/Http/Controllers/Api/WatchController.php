<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Watch;
use Illuminate\Http\Request;

class WatchController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $query = Watch::query()->with(['type', 'strap', 'features']);

        if ($request->has('search')) {
            $query->where('model', 'like', '%' . $request->search . '%');
        }
        $watches = $query->paginate(15);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'brand' => 'required|string',
            'model' => 'required|string',
            'type_id' => 'required|exists:types,id,enabled,1',
            'strap_id' => 'required|exists:straps,id,enabled,1',
            'price' => 'nullable|numeric',
            'description' => 'nullable|string',
            'features' => 'array',
            'features.*' => 'exists:features,id',
        ]);

        // Comprobar unique brand + model
        if (Watch::where('brand', $request->brand)->where('model', $request->model)->exists()) {
            return response()->json(['error' => 'Ya existe un reloj con esa marca y modelo'], 422);
        }

        $watch = Watch::create($request->only(['brand', 'model', 'type_id', 'strap_id', 'price', 'description']));
        if ($request->has('features')) {
            $watch->features()->sync($request->features);
        }

        return response()->json(['message' => 'Reloj creado correctamente', 'watch' => $watch->load('type', 'strap', 'features')], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Watch $watch)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Watch $watch)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Watch $watch)
    {
        //
    }
}
