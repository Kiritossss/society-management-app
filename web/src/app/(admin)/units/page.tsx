"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { api, ApiError } from "@/lib/api";
import type { Unit } from "@/lib/types";

export default function UnitsPage() {
  const [units, setUnits] = useState<Unit[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  async function load() {
    try {
      setUnits(await api.getUnits());
    } catch {
      setError("Failed to load units");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  async function handleDelete(id: string) {
    if (!confirm("Delete this unit?")) return;
    try {
      await api.deleteUnit(id);
      setUnits((prev) => prev.filter((u) => u.id !== id));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Delete failed");
    }
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Units</h1>
          <p className="text-muted text-sm">Manage your society layout</p>
        </div>
        <Link
          href="/units/new"
          className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-hover transition-colors"
        >
          + Add Units
        </Link>
      </div>

      {loading ? (
        <p className="text-muted">Loading...</p>
      ) : error ? (
        <p className="text-danger">{error}</p>
      ) : units.length === 0 ? (
        <div className="text-center py-16 text-muted">
          <p className="text-lg mb-2">No units yet</p>
          <p className="text-sm">Add your society&apos;s towers, floors, and flats to get started.</p>
        </div>
      ) : (
        <div className="bg-card border border-border rounded-xl overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b border-border">
              <tr>
                <th className="text-left px-4 py-3 font-medium text-muted">Unit</th>
                <th className="text-left px-4 py-3 font-medium text-muted">Block</th>
                <th className="text-left px-4 py-3 font-medium text-muted">Floor</th>
                <th className="text-left px-4 py-3 font-medium text-muted">Type</th>
                <th className="text-left px-4 py-3 font-medium text-muted">Area</th>
                <th className="text-left px-4 py-3 font-medium text-muted">Status</th>
                <th className="text-right px-4 py-3 font-medium text-muted">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {units.map((unit) => (
                <tr key={unit.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3 font-medium">{unit.unit_number}</td>
                  <td className="px-4 py-3 text-muted">{unit.block_name || "—"}</td>
                  <td className="px-4 py-3 text-muted">{unit.floor_number || "—"}</td>
                  <td className="px-4 py-3 text-muted">{unit.unit_type || "—"}</td>
                  <td className="px-4 py-3 text-muted">
                    {unit.area_sqft ? `${unit.area_sqft} sqft` : "—"}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`inline-block px-2 py-0.5 rounded-full text-xs font-medium ${
                        unit.is_occupied
                          ? "bg-green-100 text-green-700"
                          : "bg-gray-100 text-gray-600"
                      }`}
                    >
                      {unit.is_occupied ? "Occupied" : "Vacant"}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-right">
                    {!unit.is_occupied && (
                      <button
                        onClick={() => handleDelete(unit.id)}
                        className="text-danger text-xs hover:underline"
                      >
                        Delete
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
