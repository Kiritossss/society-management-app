"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { api, ApiError } from "@/lib/api";

interface UnitRow {
  unit_number: string;
  block_name: string;
  floor_number: string;
  unit_type: string;
  area_sqft: string;
}

const emptyRow = (): UnitRow => ({
  unit_number: "",
  block_name: "",
  floor_number: "",
  unit_type: "",
  area_sqft: "",
});

export default function NewUnitsPage() {
  const router = useRouter();
  const [rows, setRows] = useState<UnitRow[]>([emptyRow()]);
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  function updateRow(index: number, field: keyof UnitRow, value: string) {
    setRows((prev) =>
      prev.map((r, i) => (i === index ? { ...r, [field]: value } : r))
    );
  }

  function addRow() {
    setRows((prev) => [...prev, emptyRow()]);
  }

  function removeRow(index: number) {
    if (rows.length === 1) return;
    setRows((prev) => prev.filter((_, i) => i !== index));
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError("");
    setSubmitting(true);

    const units = rows
      .filter((r) => r.unit_number.trim())
      .map((r) => ({
        unit_number: r.unit_number.trim(),
        block_name: r.block_name.trim() || undefined,
        floor_number: r.floor_number.trim() || undefined,
        unit_type: r.unit_type.trim() || undefined,
        area_sqft: r.area_sqft ? parseFloat(r.area_sqft) : undefined,
      }));

    if (units.length === 0) {
      setError("Add at least one unit");
      setSubmitting(false);
      return;
    }

    try {
      if (units.length === 1) {
        await api.createUnit(units[0]);
      } else {
        await api.createUnitsBulk(units);
      }
      router.push("/units");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to create units");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Add Units</h1>
      <p className="text-muted text-sm mb-6">
        Add one or more units to your society layout.
      </p>

      <form onSubmit={handleSubmit}>
        {error && (
          <div className="bg-red-50 border border-red-200 text-danger text-sm rounded-lg px-4 py-3 mb-4">
            {error}
          </div>
        )}

        <div className="bg-card border border-border rounded-xl overflow-hidden mb-4">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b border-border">
              <tr>
                <th className="text-left px-3 py-2 font-medium text-muted">Unit # *</th>
                <th className="text-left px-3 py-2 font-medium text-muted">Block</th>
                <th className="text-left px-3 py-2 font-medium text-muted">Floor</th>
                <th className="text-left px-3 py-2 font-medium text-muted">Type</th>
                <th className="text-left px-3 py-2 font-medium text-muted">Area (sqft)</th>
                <th className="w-10"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {rows.map((row, i) => (
                <tr key={i}>
                  <td className="px-3 py-2">
                    <input
                      value={row.unit_number}
                      onChange={(e) => updateRow(i, "unit_number", e.target.value)}
                      placeholder="301"
                      required
                      className="w-full px-2 py-1 border border-border rounded text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                    />
                  </td>
                  <td className="px-3 py-2">
                    <input
                      value={row.block_name}
                      onChange={(e) => updateRow(i, "block_name", e.target.value)}
                      placeholder="Tower A"
                      className="w-full px-2 py-1 border border-border rounded text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                    />
                  </td>
                  <td className="px-3 py-2">
                    <input
                      value={row.floor_number}
                      onChange={(e) => updateRow(i, "floor_number", e.target.value)}
                      placeholder="3"
                      className="w-full px-2 py-1 border border-border rounded text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                    />
                  </td>
                  <td className="px-3 py-2">
                    <input
                      value={row.unit_type}
                      onChange={(e) => updateRow(i, "unit_type", e.target.value)}
                      placeholder="2BHK"
                      className="w-full px-2 py-1 border border-border rounded text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                    />
                  </td>
                  <td className="px-3 py-2">
                    <input
                      type="number"
                      value={row.area_sqft}
                      onChange={(e) => updateRow(i, "area_sqft", e.target.value)}
                      placeholder="850"
                      className="w-full px-2 py-1 border border-border rounded text-sm focus:outline-none focus:ring-1 focus:ring-primary"
                    />
                  </td>
                  <td className="px-3 py-2">
                    {rows.length > 1 && (
                      <button
                        type="button"
                        onClick={() => removeRow(i)}
                        className="text-danger hover:underline text-xs"
                      >
                        &times;
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="flex items-center gap-4">
          <button
            type="button"
            onClick={addRow}
            className="text-primary text-sm font-medium hover:underline"
          >
            + Add another row
          </button>
          <div className="flex-1" />
          <button
            type="button"
            onClick={() => router.back()}
            className="px-4 py-2 text-sm text-muted border border-border rounded-lg hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={submitting}
            className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-hover disabled:opacity-50 transition-colors"
          >
            {submitting ? "Creating..." : `Create ${rows.filter((r) => r.unit_number.trim()).length} Unit(s)`}
          </button>
        </div>
      </form>
    </div>
  );
}
