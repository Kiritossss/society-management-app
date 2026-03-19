"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { api, ApiError } from "@/lib/api";
import type { User } from "@/lib/types";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

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

  // Import state
  const [showImport, setShowImport] = useState(false);
  const [importing, setImporting] = useState(false);
  const [importResult, setImportResult] = useState<{
    created: number;
    errors: number;
    details: Array<Record<string, string>>;
    error_details: Array<{ row: number; error: string }>;
  } | null>(null);
  const fileRef = useRef<HTMLInputElement>(null);

  async function load() {
    try {
      setMembers(await api.getMembers());
    } catch {
      // ignore
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

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

  async function handleImport() {
    const file = fileRef.current?.files?.[0];
    if (!file) return;
    setImporting(true);
    setImportResult(null);
    try {
      const result = await api.importMembers(file);
      setImportResult(result);
      if (result.created > 0) {
        load();
      }
    } catch (err) {
      setImportResult({
        created: 0,
        errors: 1,
        details: [],
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
          <h1 className="text-2xl font-bold">Members</h1>
          <p className="text-muted text-sm">Manage residents and staff</p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={() => { setShowImport(!showImport); setImportResult(null); }}
            className="border border-primary text-primary px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary hover:text-white transition-colors"
          >
            Import from File
          </button>
          <Link
            href="/members/new"
            className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-hover transition-colors"
          >
            + Add Member
          </Link>
        </div>
      </div>

      {/* Import Panel */}
      {showImport && (
        <div className="bg-card border border-border rounded-xl p-6 mb-6">
          <h2 className="font-semibold mb-3">Import Members from Excel / CSV</h2>
          <p className="text-sm text-muted mb-4">
            Upload a <strong>.xlsx</strong> or <strong>.csv</strong> file with columns:
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">full_name</code>,
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">email</code> (required),
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">role</code> (default: member),
            <code className="bg-gray-100 px-1 mx-1 rounded text-xs">unit_number</code>.
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
              href={`${API_BASE}/api/v1/members/import/template`}
              className="text-primary text-sm hover:underline"
            >
              Download template
            </a>
          </div>

          {importResult && (
            <div className={`rounded-lg p-4 text-sm ${importResult.errors > 0 ? "bg-yellow-50 border border-yellow-200" : "bg-green-50 border border-green-200"}`}>
              <p className="font-medium mb-1">
                {importResult.created} member{importResult.created !== 1 ? "s" : ""} created
                {importResult.errors > 0 && `, ${importResult.errors} error${importResult.errors !== 1 ? "s" : ""}`}
              </p>

              {/* Show invite tokens for created members */}
              {importResult.details.length > 0 && (
                <div className="mt-3 bg-white border border-green-200 rounded-lg overflow-hidden">
                  <table className="w-full text-xs">
                    <thead className="bg-green-50">
                      <tr>
                        <th className="text-left px-3 py-2 font-medium">Name</th>
                        <th className="text-left px-3 py-2 font-medium">Email</th>
                        <th className="text-left px-3 py-2 font-medium">Invite Token</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-green-100">
                      {importResult.details.map((d, i) => (
                        <tr key={i}>
                          <td className="px-3 py-2">{d.full_name}</td>
                          <td className="px-3 py-2 text-muted">{d.email}</td>
                          <td className="px-3 py-2 font-mono">
                            {d.invite_token}
                            <button
                              onClick={() => navigator.clipboard.writeText(d.invite_token)}
                              className="ml-2 text-primary hover:underline"
                            >
                              Copy
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}

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
