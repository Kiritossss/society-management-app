"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { api, ApiError } from "@/lib/api";
import type { Notice } from "@/lib/types";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

const priorityColors: Record<string, string> = {
  normal: "bg-gray-100 text-gray-700",
  important: "bg-yellow-100 text-yellow-700",
  urgent: "bg-red-100 text-red-700",
};

const priorityOptions = ["normal", "important", "urgent"];

export default function NoticesPage() {
  const [notices, setNotices] = useState<Notice[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("all");

  useEffect(() => {
    api.getNotices().then(setNotices).finally(() => setLoading(false));
  }, []);

  async function handlePriorityChange(id: string, priority: string) {
    try {
      const updated = await api.updateNotice(id, { priority });
      setNotices((prev) => prev.map((n) => (n.id === updated.id ? updated : n)));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Update failed");
    }
  }

  async function handleTogglePin(id: string, currentlyPinned: boolean) {
    try {
      const updated = await api.updateNotice(id, { is_pinned: !currentlyPinned });
      setNotices((prev) => prev.map((n) => (n.id === updated.id ? updated : n)));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Update failed");
    }
  }

  async function handleDelete(id: string) {
    if (!confirm("Delete this notice?")) return;
    try {
      await api.deleteNotice(id);
      setNotices((prev) => prev.filter((n) => n.id !== id));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Delete failed");
    }
  }

  const filtered =
    filter === "all"
      ? notices
      : filter === "pinned"
        ? notices.filter((n) => n.is_pinned)
        : notices.filter((n) => n.priority === filter);

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Notice Board</h1>
          <p className="text-muted text-sm">Post and manage society announcements</p>
        </div>
        <Link
          href="/notices/new"
          className="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 transition-colors text-sm font-medium"
        >
          + Post Notice
        </Link>
      </div>

      <div className="flex gap-2 mb-4">
        {["all", "pinned", ...priorityOptions].map((s) => (
          <button
            key={s}
            onClick={() => setFilter(s)}
            className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
              filter === s
                ? "bg-primary text-white"
                : "bg-gray-100 text-muted hover:bg-gray-200"
            }`}
          >
            {s === "all" ? "All" : s === "pinned" ? "Pinned" : s}
            {s === "all"
              ? ` (${notices.length})`
              : s === "pinned"
                ? ` (${notices.filter((n) => n.is_pinned).length})`
                : ` (${notices.filter((n) => n.priority === s).length})`}
          </button>
        ))}
      </div>

      {loading ? (
        <p className="text-muted">Loading...</p>
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 text-muted">
          <p className="text-lg">No notices found</p>
          <p className="text-sm mt-1">Post the first notice using the button above</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((n) => (
            <div
              key={n.id}
              className={`bg-card border rounded-xl p-4 ${
                n.is_pinned ? "border-primary/40 bg-primary/5" : "border-border"
              }`}
            >
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    {n.is_pinned && (
                      <span className="text-primary text-sm" title="Pinned">
                        <svg className="w-4 h-4 inline" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M10 2a1 1 0 011 1v1.323l3.954 1.582 1.599-.8a1 1 0 01.894 1.79l-1.233.616L17 11a1 1 0 01-.293.707l-2 2A1 1 0 0114 14h-1v4a1 1 0 11-2 0v-4H6a1 1 0 01-.707-.293l-2-2A1 1 0 013 11l.786-3.489-1.233-.616a1 1 0 01.894-1.789l1.599.799L9 4.323V3a1 1 0 011-1z" />
                        </svg>
                      </span>
                    )}
                    <h3 className="font-medium">{n.title}</h3>
                    <span
                      className={`inline-block px-2 py-0.5 rounded-full text-xs font-medium ${priorityColors[n.priority]}`}
                    >
                      {n.priority}
                    </span>
                  </div>
                  <p className="text-sm text-muted whitespace-pre-line line-clamp-3">
                    {n.body}
                  </p>
                  {n.image_url && (
                    <img
                      src={`${API_BASE}${n.image_url}`}
                      alt=""
                      className="mt-2 max-h-40 rounded-lg border border-border object-cover"
                    />
                  )}
                  <p className="text-xs text-muted mt-2">
                    Posted {new Date(n.created_at).toLocaleDateString()}
                    {n.updated_at !== n.created_at &&
                      ` · Edited ${new Date(n.updated_at).toLocaleDateString()}`}
                  </p>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <select
                    value={n.priority}
                    onChange={(e) => handlePriorityChange(n.id, e.target.value)}
                    className="text-xs border border-border rounded px-2 py-1 focus:outline-none focus:ring-1 focus:ring-primary"
                  >
                    {priorityOptions.map((p) => (
                      <option key={p} value={p}>
                        {p}
                      </option>
                    ))}
                  </select>
                  <button
                    onClick={() => handleTogglePin(n.id, n.is_pinned)}
                    className={`px-2 py-1 text-xs rounded transition-colors ${
                      n.is_pinned
                        ? "bg-primary text-white hover:bg-primary/80"
                        : "bg-gray-100 text-muted hover:bg-gray-200"
                    }`}
                    title={n.is_pinned ? "Unpin" : "Pin"}
                  >
                    {n.is_pinned ? "Unpin" : "Pin"}
                  </button>
                  <button
                    onClick={() => handleDelete(n.id)}
                    className="px-2 py-1 text-xs bg-red-600 text-white rounded hover:bg-red-700 transition-colors"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
