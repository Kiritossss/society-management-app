"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import type { Unit, Complaint, VisitorLog } from "@/lib/types";
import { useAuth } from "@/lib/auth-context";

export default function DashboardPage() {
  const { user } = useAuth();
  const [stats, setStats] = useState({
    units: 0,
    members: 0,
    openComplaints: 0,
    occupiedUnits: 0,
    visitorsInside: 0,
    pendingApprovals: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const [units, members, complaints, visitors] = await Promise.all([
          api.getUnits(),
          api.getMembers(),
          api.getComplaints(),
          api.getVisitors(0, 200),
        ]);
        setStats({
          units: units.length,
          members: members.length,
          openComplaints: complaints.filter(
            (c: Complaint) => c.status === "open" || c.status === "in_progress"
          ).length,
          occupiedUnits: units.filter((u: Unit) => u.is_occupied).length,
          visitorsInside: visitors.filter(
            (v: VisitorLog) => v.status === "checked_in"
          ).length,
          pendingApprovals: visitors.filter(
            (v: VisitorLog) => v.status === "pending"
          ).length,
        });
      } catch {
        // If API fails, keep zeros
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  const cards = [
    { label: "Total Units", value: stats.units, color: "bg-blue-500" },
    { label: "Occupied Units", value: stats.occupiedUnits, color: "bg-green-500" },
    { label: "Total Members", value: stats.members, color: "bg-indigo-500" },
    { label: "Open Complaints", value: stats.openComplaints, color: "bg-orange-500" },
    { label: "Visitors Inside", value: stats.visitorsInside, color: "bg-emerald-500" },
    { label: "Pending Approvals", value: stats.pendingApprovals, color: "bg-yellow-500" },
  ];

  return (
    <div>
      <h1 className="text-2xl font-bold mb-1">Dashboard</h1>
      <p className="text-muted text-sm mb-8">
        Welcome back, {user?.full_name}
      </p>

      {loading ? (
        <p className="text-muted">Loading stats...</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {cards.map((card) => (
            <div
              key={card.label}
              className="bg-card border border-border rounded-xl p-6"
            >
              <div className="flex items-center gap-3 mb-3">
                <div className={`w-3 h-3 rounded-full ${card.color}`} />
                <span className="text-sm text-muted">{card.label}</span>
              </div>
              <p className="text-3xl font-bold">{card.value}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
