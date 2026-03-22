"use client";

import { useEffect, useState } from "react";
import { api, ApiError } from "@/lib/api";
import type { Complaint, ComplaintComment } from "@/lib/types";

const statusColors: Record<string, string> = {
  open: "bg-red-100 text-red-700",
  in_progress: "bg-yellow-100 text-yellow-700",
  resolved: "bg-green-100 text-green-700",
  closed: "bg-gray-100 text-gray-600",
};

const categoryColors: Record<string, string> = {
  maintenance: "bg-blue-50 text-blue-600",
  noise: "bg-purple-50 text-purple-600",
  cleanliness: "bg-teal-50 text-teal-600",
  security: "bg-red-50 text-red-600",
  other: "bg-gray-50 text-gray-600",
};

const statusOptions = ["open", "in_progress", "resolved", "closed"];

export default function ComplaintsPage() {
  const [complaints, setComplaints] = useState<Complaint[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("all");
  const [expandedId, setExpandedId] = useState<string | null>(null);

  useEffect(() => {
    api.getComplaints().then(setComplaints).finally(() => setLoading(false));
  }, []);

  async function handleStatusChange(id: string, newStatus: string) {
    try {
      const updated = await api.updateComplaintStatus(id, newStatus);
      setComplaints((prev) => prev.map((c) => (c.id === updated.id ? updated : c)));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Update failed");
    }
  }

  async function handleDelete(id: string) {
    if (!confirm("Delete this complaint?")) return;
    try {
      await api.deleteComplaint(id);
      setComplaints((prev) => prev.filter((c) => c.id !== id));
      if (expandedId === id) setExpandedId(null);
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Delete failed");
    }
  }

  const filtered =
    filter === "all"
      ? complaints
      : complaints.filter((c) => c.status === filter);

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Complaints</h1>
          <p className="text-muted text-sm">Review and manage resident complaints</p>
        </div>
      </div>

      <div className="flex gap-2 mb-4">
        {["all", ...statusOptions].map((s) => (
          <button
            key={s}
            onClick={() => setFilter(s)}
            className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
              filter === s
                ? "bg-primary text-white"
                : "bg-gray-100 text-muted hover:bg-gray-200"
            }`}
          >
            {s === "all" ? "All" : s.replace("_", " ")}
            {s !== "all" &&
              ` (${complaints.filter((c) => c.status === s).length})`}
          </button>
        ))}
      </div>

      {loading ? (
        <p className="text-muted">Loading...</p>
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 text-muted">
          <p className="text-lg">No complaints found</p>
        </div>
      ) : (
        <div className="space-y-3">
          {filtered.map((c) => (
            <div
              key={c.id}
              className="bg-card border border-border rounded-xl p-4"
            >
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <h3 className="font-medium">{c.title}</h3>
                    <span
                      className={`inline-block px-2 py-0.5 rounded-full text-xs font-medium ${categoryColors[c.category]}`}
                    >
                      {c.category}
                    </span>
                  </div>
                  <p className="text-sm text-muted line-clamp-2">
                    {c.description}
                  </p>
                  <p className="text-xs text-muted mt-2">
                    {new Date(c.created_at).toLocaleDateString()}
                    {c.resolved_at &&
                      ` — Resolved ${new Date(c.resolved_at).toLocaleDateString()}`}
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <span
                    className={`inline-block px-2 py-0.5 rounded-full text-xs font-medium whitespace-nowrap ${statusColors[c.status]}`}
                  >
                    {c.status.replace("_", " ")}
                  </span>
                  <select
                    value={c.status}
                    onChange={(e) => handleStatusChange(c.id, e.target.value)}
                    className="text-xs border border-border rounded px-2 py-1 focus:outline-none focus:ring-1 focus:ring-primary"
                  >
                    {statusOptions.map((s) => (
                      <option key={s} value={s}>
                        {s.replace("_", " ")}
                      </option>
                    ))}
                  </select>
                  {(c.status === "resolved" || c.status === "closed") && (
                    <button
                      onClick={() => handleDelete(c.id)}
                      className="px-2 py-1 text-xs bg-red-600 text-white rounded hover:bg-red-700 transition-colors"
                    >
                      Delete
                    </button>
                  )}
                </div>
              </div>

              {/* Comments toggle */}
              <div className="mt-3 pt-3 border-t border-border">
                <button
                  onClick={() =>
                    setExpandedId(expandedId === c.id ? null : c.id)
                  }
                  className="text-xs font-medium text-primary hover:underline"
                >
                  {expandedId === c.id ? "Hide Comments" : "View Comments"}
                </button>
                {expandedId === c.id && <CommentThread complaintId={c.id} />}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function CommentThread({ complaintId }: { complaintId: string }) {
  const [comments, setComments] = useState<ComplaintComment[]>([]);
  const [loading, setLoading] = useState(true);
  const [body, setBody] = useState("");
  const [sending, setSending] = useState(false);

  useEffect(() => {
    api
      .getComplaintComments(complaintId)
      .then(setComments)
      .finally(() => setLoading(false));
  }, [complaintId]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!body.trim()) return;
    setSending(true);
    try {
      const comment = await api.addComplaintComment(complaintId, body.trim());
      setComments((prev) => [...prev, comment]);
      setBody("");
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Failed to add comment");
    } finally {
      setSending(false);
    }
  }

  async function handleDeleteComment(commentId: string) {
    try {
      await api.deleteComplaintComment(complaintId, commentId);
      setComments((prev) => prev.filter((c) => c.id !== commentId));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Failed to delete comment");
    }
  }

  if (loading) {
    return <p className="text-xs text-muted mt-2">Loading comments...</p>;
  }

  return (
    <div className="mt-3 space-y-3">
      {comments.length === 0 && (
        <p className="text-xs text-muted">No comments yet.</p>
      )}
      {comments.map((c) => (
        <div key={c.id} className="flex gap-2 group">
          <div className="w-7 h-7 rounded-full bg-primary/10 text-primary flex items-center justify-center text-xs font-semibold flex-shrink-0">
            {c.user_name.charAt(0).toUpperCase()}
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2">
              <span className="text-xs font-medium">{c.user_name}</span>
              <span className="text-xs text-muted">
                {new Date(c.created_at).toLocaleString()}
              </span>
              <button
                onClick={() => handleDeleteComment(c.id)}
                className="text-xs text-red-500 opacity-0 group-hover:opacity-100 transition-opacity"
              >
                Delete
              </button>
            </div>
            <p className="text-sm mt-0.5 whitespace-pre-wrap">{c.body}</p>
          </div>
        </div>
      ))}

      <form onSubmit={handleSubmit} className="flex gap-2">
        <input
          type="text"
          value={body}
          onChange={(e) => setBody(e.target.value)}
          placeholder="Write a comment..."
          maxLength={2000}
          className="flex-1 text-sm border border-border rounded-lg px-3 py-1.5 focus:outline-none focus:ring-1 focus:ring-primary"
        />
        <button
          type="submit"
          disabled={sending || !body.trim()}
          className="px-3 py-1.5 text-sm bg-primary text-white rounded-lg hover:bg-primary/90 disabled:opacity-50 transition-colors"
        >
          {sending ? "..." : "Send"}
        </button>
      </form>
    </div>
  );
}
