"use client";

import { useState, useEffect, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { api, ApiError } from "@/lib/api";
import type { Unit } from "@/lib/types";

export default function NewMemberPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("member");
  const [unitId, setUnitId] = useState("");
  const [units, setUnits] = useState<Unit[]>([]);
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [inviteToken, setInviteToken] = useState<string | null>(null);

  useEffect(() => {
    api.getUnits().then(setUnits).catch(() => {});
  }, []);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError("");
    setSubmitting(true);

    try {
      const res = await api.createMember({
        full_name: fullName,
        email,
        role,
        unit_id: unitId || undefined,
      });
      setInviteToken(res.invite_token);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Failed to create member");
    } finally {
      setSubmitting(false);
    }
  }

  if (inviteToken) {
    return (
      <div className="max-w-lg">
        <h1 className="text-2xl font-bold mb-4">Member Created</h1>
        <div className="bg-green-50 border border-green-200 rounded-xl p-6">
          <p className="text-sm text-green-800 mb-2">
            Share this invite token with <strong>{fullName}</strong> so they can
            activate their account in the mobile app:
          </p>
          <div className="bg-white border border-green-300 rounded-lg px-4 py-3 font-mono text-lg text-center select-all">
            {inviteToken}
          </div>
          <div className="flex gap-3 mt-4">
            <button
              onClick={() => navigator.clipboard.writeText(inviteToken)}
              className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-hover transition-colors"
            >
              Copy Token
            </button>
            <button
              onClick={() => router.push("/members")}
              className="px-4 py-2 text-sm text-muted border border-border rounded-lg hover:bg-gray-50"
            >
              Back to Members
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-lg">
      <h1 className="text-2xl font-bold mb-1">Add Member</h1>
      <p className="text-muted text-sm mb-6">
        An invite token will be generated for the member to activate their account.
      </p>

      <form onSubmit={handleSubmit} className="space-y-4">
        {error && (
          <div className="bg-red-50 border border-red-200 text-danger text-sm rounded-lg px-4 py-3">
            {error}
          </div>
        )}

        <div>
          <label className="block text-sm font-medium mb-1">Full Name</label>
          <input
            type="text"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            required
            className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Email</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">Role</label>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="member">Member (Resident)</option>
            <option value="committee">Committee</option>
            <option value="support_staff">Support Staff</option>
            <option value="admin">Admin</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">
            Unit (optional)
          </label>
          <select
            value={unitId}
            onChange={(e) => setUnitId(e.target.value)}
            className="w-full px-3 py-2 border border-border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="">No unit assigned</option>
            {units.map((u) => (
              <option key={u.id} value={u.id}>
                {[u.block_name, u.floor_number ? `Floor ${u.floor_number}` : null, u.unit_number]
                  .filter(Boolean)
                  .join(" / ")}
                {u.is_occupied ? " (occupied)" : ""}
              </option>
            ))}
          </select>
        </div>

        <div className="flex gap-3 pt-2">
          <button
            type="submit"
            disabled={submitting}
            className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary-hover disabled:opacity-50 transition-colors"
          >
            {submitting ? "Creating..." : "Create & Get Invite Token"}
          </button>
          <button
            type="button"
            onClick={() => router.back()}
            className="px-4 py-2 text-sm text-muted border border-border rounded-lg hover:bg-gray-50"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}
