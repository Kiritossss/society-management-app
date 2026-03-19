"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { api, ApiError } from "@/lib/api";
import type { Unit } from "@/lib/types";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

export default function UnitsPage() {
  const [units, setUnits] = useState<Unit[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // Import state
  const [showImport, setShowImport] = useState(false);
  const [importing, setImporting] = useState(false);
  const [importResult, setImportResult] = useState<{
    created: number;
    errors: number;
    error_details: Array<{ row: number; error: string }>;
  } | null>(null);
  const fileRef = useRef<HTMLInputElement>(null);

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

  async function handleImport() {
    const file = fileRef.current?.files?.[0];
    if (!file) return;
    setImporting(true);
    setImportResult(null);
    try {
      const result = await api.importUnits(file);
      setImportResult(result);
      if (result.created > 0) {
        load(); // refresh the table
      }
    } catch (err) {
      setImportResult({
        created: 0,
        errors: 1,
        error_details: [{ row: 0, error: err instanceof ApiError ? err.message : "Import failed" }],
      });
    } finally {
      setImporting(false);
    }
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Units</h1>
          <p className="text-muted text-sm">Manage your society layout</p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={() => { setShowImport(!showImport); setImportResult(null); }}
            className="border border-primary text-primary px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary hover:text-white transition-colors"
          >
            Import from File
          </button>
          <Link
            href="/units/new"
            className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-hover transition-colors"
          >
            + Add Units
          </Link>
        </div>
      </div>

      {/* Import Panel */}
      {showImport && (
        <div className="bg-card border border-border rounded-xl p-6 mb-6">
          <h2 className="font-semibold mb-3">Import Units from Excel / CSV</h2>
          <p className="text-sm text-muted mb-4">
            Upload a <strong>.xlsx</strong> or <strong>.csv</strong> file with columns:
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">unit_number</code> (required),
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">block_name</code>,
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">floor_number</code>,
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">unit_type</code>,
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">area_sqft</code>.
          </p>

          <div className="flex items-center gap-4 mb-4">
            <input
              ref={fileRef}
              type="file"
              accept=".xlsx,.csv"
              className="text-sm file:mr-3 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-primary file:text-white file:text-sm file:font-medium file:cursor-pointer"
            />
            <button
              onClick={handleImport}
              disabled={importing}
              className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-hover transition-colors disabled:opacity-50"
            >
              {importing ? "Importing..." : "Upload & Import"}
            </button>
            <a
              href={`${API_BASE}/api/v1/units/import/template`}
              className="text-primary text-sm hover:underline"
            >
              Download template
            </a>
          </div>

          {importResult && (
            <div className={`rounded-lg p-4 text-sm ${importResult.errors > 0 ? "bg-yellow-50 border border-yellow-200" : "bg-green-50 border border-green-200"}`}>
              <p className="font-medium mb-1">
                {importResult.created} unit{importResult.created !== 1 ? "s" : ""} created
                {importResult.errors > 0 && `, ${importResult.errors} error${importResult.errors !== 1 ? "s" : ""}`}
              </p>
              {importResult.error_details.length > 0 && (
                <ul className="mt-2 space-y-1 text-red-600">
                  {importResult.error_details.map((e, i) => (
                    <li key={i}>Row {e.row}: {e.error}</li>
                  ))}
                </ul>
              )}
            </div>
          )}
        </div>
      )}

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
