"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { api, ApiError } from "@/lib/api";
import type { User } from "@/lib/types";

const roleBadge: Record<string, string> = {
  admin: "bg-purple-100 text-purple-700",
  committee: "bg-blue-100 text-blue-700",
  support_staff: "bg-yellow-100 text-yellow-700",
  member: "bg-gray-100 text-gray-600",
};

export default function MembersPage() {
  const [members, setMembers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [inviteToken, setInviteToken] = useState<string | null>(null);

  useEffect(() => {
    api.getMembers().then(setMembers).finally(() => setLoading(false));
  }, []);

  async function handleReinvite(userId: string) {
    try {
      const res = await api.reinviteMember(userId);
      setInviteToken(res.invite_token);
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Reinvite failed");
    }
  }

  async function handleDeactivate(userId: string) {
    if (!confirm("Deactivate this member?")) return;
    try {
      const updated = await api.deactivateMember(userId);
      setMembers((prev) => prev.map((m) => (m.id === updated.id ? updated : m)));
    } catch (err) {
      alert(err instanceof ApiError ? err.message : "Deactivate failed");
    }
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold">Members</h1>
          <p className="text-muted text-sm">Manage residents and staff</p>
        </div>
        <Link
          href="/members/new"
          className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-hover transition-colors"
        >
          + Add Member
        </Link>
      </div>

      {inviteToken && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg px-4 py-3 mb-4 flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-blue-800">Invite token generated</p>
            <p className="font-mono text-sm text-blue-900 mt-1">{inviteToken}</p>
          </div>
          <button
            onClick={() => {
              navigator.clipboard.writeText(inviteToken);
              setInviteToken(null);
            }}
            className="text-sm text-blue-700 font-medium hover:underline"
          >
            Copy & dismiss
          </button>
        </div>
      )}

      {loading ? (
        <p className="text-muted">Loading...</p>
      ) : members.length === 0 ? (
        <div className="text-center py-16 text-muted">
          <p className="text-lg mb-2">No members yet</p>
          <p className="text-sm">Add members and share their invite tokens to get started.</p>
        </div>
      ) : (
        <div className="bg-card border border-border rounded-xl overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b border-border">
              <tr>
                <th className="text-left px-4 py-3 font-medium text-muted">Name</th>
                <th className="text-left px-4 py-3 font-medium text-muted">Email</th>
                <th className="text-left px-4 py-3 font-medium text-muted">Role</th>
                <th className="text-left px-4 py-3 font-medium text-muted">Status</th>
                <th className="text-right px-4 py-3 font-medium text-muted">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {members.map((m) => (
                <tr key={m.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3 font-medium">{m.full_name}</td>
                  <td className="px-4 py-3 text-muted">{m.email}</td>
                  <td className="px-4 py-3">
                    <span className={`inline-block px-2 py-0.5 rounded-full text-xs font-medium ${roleBadge[m.role] || roleBadge.member}`}>
                      {m.role.replace("_", " ")}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {!m.is_active ? (
                      <span className="text-xs text-danger">Deactivated</span>
                    ) : !m.is_activated ? (
                      <span className="text-xs text-warning">Pending invite</span>
                    ) : (
                      <span className="text-xs text-success">Active</span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-right space-x-3">
                    {!m.is_activated && m.is_active && (
                      <button
                        onClick={() => handleReinvite(m.id)}
                        className="text-primary text-xs hover:underline"
                      >
                        Reinvite
                      </button>
                    )}
                    {m.is_active && m.role !== "admin" && (
                      <button
                        onClick={() => handleDeactivate(m.id)}
                        className="text-danger text-xs hover:underline"
                      >
                        Deactivate
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
