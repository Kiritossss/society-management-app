"use client";

import { useEffect, useState } from "react";
import { api, ApiError } from "@/lib/api";
import type { VisitorLog, VisitStatus } from "@/lib/types";

const statusColors: Record<string, string> = {
  pre_approved: "bg-blue-100 text-blue-700",
  pending: "bg-yellow-100 text-yellow-700",
  approved: "bg-green-100 text-green-700",
  denied: "bg-red-100 text-red-700",
  checked_in: "bg-emerald-100 text-emerald-700",
  checked_out: "bg-gray-100 text-gray-600",
};

const purposeColors: Record<string, string> = {
  guest: "bg-purple-50 text-purple-600",
  delivery: "bg-orange-50 text-orange-600",
  cab: "bg-blue-50 text-blue-600",
  service: "bg-teal-50 text-teal-600",
  other: "bg-gray-50 text-gray-600",
};

const statusFilters: Array<{ value: string; label: string }> = [
  { value: "all", label: "All" },
  { value: "pre_approved", label: "Pre-approved" },
  { value: "pending", label: "Pending" },
  { value: "approved", label: "Approved" },
  { value: "checked_in", label: "Checked In" },
  { value: "checked_out", label: "Checked Out" },
  { value: "denied", label: "Denied" },
];

export default function VisitorsPage() {
  const [visitors, setVisitors] = useState<VisitorLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("all");

  useEffect(() => {
    api.getVisitors(0, 200).then(setVisitors).finally(() => setLoading(false));
  }, []);

  async function handleCheckIn(id: string) {
    try {
      const updated = await api.checkInVisitor(id);
      setVisitors((prev) => prev.map((v) => (v.id === updated.id ? updated : v)));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Check-in failed");
    }
  }

  async function handleCheckOut(id: string) {
    try {
      const updated = await api.checkOutVisitor(id);
      setVisitors((prev) => prev.map((v) => (v.id === updated.id ? updated : v)));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Check-out failed");
    }
  }

  async function handleDeleteVisitor(id: string) {
    if (!confirm("Delete this visitor record?")) return;
    try {
      await api.deleteVisitor(id);
      setVisitors((prev) => prev.filter((v) => v.id !== id));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Delete failed");
    }
  }

  const filtered =
    filter === "all"
      ? visitors
      : visitors.filter((v) => v.status === filter);

  const counts = visitors.reduce(
    (acc, v) => {
      acc[v.status] = (acc[v.status] || 0) + 1;
      return acc;
    },
    {} as Record<string, number>
  );

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Visitor Log</h1>
          <p className="text-muted text-sm">
            Monitor and manage visitor entry/exit across the society
          </p>
        </div>
        <div className="flex gap-3 text-sm">
          <div className="bg-emerald-50 text-emerald-700 px-3 py-1.5 rounded-lg font-medium">
            {counts["checked_in"] || 0} currently inside
          </div>
          <div className="bg-yellow-50 text-yellow-700 px-3 py-1.5 rounded-lg font-medium">
            {counts["pending"] || 0} pending approval
          </div>
        </div>
      </div>

      {/* Filter tabs */}
      <div className="flex gap-2 mb-4 flex-wrap">
        {statusFilters.map((s) => (
          <button
            key={s.value}
            onClick={() => setFilter(s.value)}
            className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
              filter === s.value
                ? "bg-primary text-white"
                : "bg-gray-100 text-muted hover:bg-gray-200"
            }`}
          >
            {s.label}
            {s.value !== "all" && counts[s.value]
              ? ` (${counts[s.value]})`
              : ""}
          </button>
        ))}
      </div>

      {loading ? (
        <p className="text-muted">Loading...</p>
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 text-muted">
          <p className="text-lg">No visitor records found</p>
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border text-left text-muted">
                <th className="pb-3 font-medium">Visitor</th>
                <th className="pb-3 font-medium">Purpose</th>
                <th className="pb-3 font-medium">Count</th>
                <th className="pb-3 font-medium">Vehicle</th>
                <th className="pb-3 font-medium">Status</th>
                <th className="pb-3 font-medium">Time</th>
                <th className="pb-3 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {filtered.map((v) => (
                <tr key={v.id} className="hover:bg-gray-50">
                  <td className="py-3">
                    <div className="font-medium">{v.visitor_name}</div>
                    {v.visitor_phone && (
                      <div className="text-xs text-muted">{v.visitor_phone}</div>
                    )}
                  </td>
                  <td className="py-3">
                    <span
                      className={`inline-block px-2 py-0.5 rounded-full text-xs font-medium ${purposeColors[v.purpose]}`}
                    >
                      {v.purpose}
                    </span>
                  </td>
                  <td className="py-3">{v.visitor_count}</td>
                  <td className="py-3 text-muted">
                    {v.vehicle_number || "—"}
                  </td>
                  <td className="py-3">
                    <span
                      className={`inline-block px-2 py-0.5 rounded-full text-xs font-medium whitespace-nowrap ${statusColors[v.status]}`}
                    >
                      {v.status.replace(/_/g, " ")}
                    </span>
                  </td>
                  <td className="py-3 text-xs text-muted">
                    <div>In: {v.checked_in_at ? new Date(v.checked_in_at).toLocaleTimeString() : "—"}</div>
                    <div>Out: {v.checked_out_at ? new Date(v.checked_out_at).toLocaleTimeString() : "—"}</div>
                  </td>
                  <td className="py-3">
                    <div className="flex gap-1">
                      {(v.status === "pre_approved" || v.status === "approved") && (
                        <button
                          onClick={() => handleCheckIn(v.id)}
                          className="px-2 py-1 text-xs bg-emerald-600 text-white rounded hover:bg-emerald-700 transition-colors"
                        >
                          Check In
                        </button>
                      )}
                      {v.status === "checked_in" && (
                        <button
                          onClick={() => handleCheckOut(v.id)}
                          className="px-2 py-1 text-xs bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
                        >
                          Check Out
                        </button>
                      )}
                      {(v.status === "checked_out" || v.status === "denied") && (
                        <button
                          onClick={() => handleDeleteVisitor(v.id)}
                          className="px-2 py-1 text-xs bg-red-600 text-white rounded hover:bg-red-700 transition-colors"
                        >
                          Delete
                        </button>
                      )}
                    </div>
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
