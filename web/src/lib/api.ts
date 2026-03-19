const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

class ApiError extends Error {
  status: number;
  constructor(message: string, status: number) {
    super(message);
    this.status = status;
  }
}

async function request<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const token =
    typeof window !== "undefined" ? localStorage.getItem("token") : null;

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    ...(options.headers as Record<string, string>),
  };
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({ detail: res.statusText }));
    throw new ApiError(body.detail || res.statusText, res.status);
  }

  if (res.status === 204) return undefined as T;
  return res.json();
}

interface ImportResult {
  created: number;
  errors: number;
  details: Array<Record<string, string>>;
  error_details: Array<{ row: number; error: string }>;
}

async function uploadFile<T>(path: string, file: File): Promise<T> {
  const token =
    typeof window !== "undefined" ? localStorage.getItem("token") : null;

  const formData = new FormData();
  formData.append("file", file);

  const headers: Record<string, string> = {};
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const res = await fetch(`${API_BASE}${path}`, {
    method: "POST",
    headers,
    body: formData,
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({ detail: res.statusText }));
    throw new ApiError(body.detail || res.statusText, res.status);
  }
  return res.json();
}

// Auth
export const api = {
  // Auth
  login(society_id: string, email: string, password: string) {
    return request<import("./types").TokenResponse>(
      `/api/v1/auth/login?society_id=${society_id}`,
      { method: "POST", body: JSON.stringify({ email, password }) }
    );
  },

  // Units
  getUnits(skip = 0, limit = 100) {
    return request<import("./types").Unit[]>(
      `/api/v1/units/?skip=${skip}&limit=${limit}`
    );
  },
  createUnit(data: {
    unit_number: string;
    block_name?: string;
    floor_number?: string;
    unit_type?: string;
    area_sqft?: number;
  }) {
    return request<import("./types").Unit>("/api/v1/units/", {
      method: "POST",
      body: JSON.stringify(data),
    });
  },
  createUnitsBulk(units: Array<{
    unit_number: string;
    block_name?: string;
    floor_number?: string;
    unit_type?: string;
    area_sqft?: number;
  }>) {
    return request<import("./types").Unit[]>("/api/v1/units/bulk", {
      method: "POST",
      body: JSON.stringify({ units }),
    });
  },
  deleteUnit(id: string) {
    return request<void>(`/api/v1/units/${id}`, { method: "DELETE" });
  },
  importUnits(file: File) {
    return uploadFile<ImportResult>("/api/v1/units/import", file);
  },

  // Members
  getMembers(skip = 0, limit = 100) {
    return request<import("./types").User[]>(
      `/api/v1/members/?skip=${skip}&limit=${limit}`
    );
  },
  createMember(data: {
    full_name: string;
    email: string;
    role?: string;
    unit_id?: string;
  }) {
    return request<import("./types").MemberInvite>("/api/v1/members/", {
      method: "POST",
      body: JSON.stringify(data),
    });
  },
  reinviteMember(userId: string) {
    return request<import("./types").MemberInvite>(
      `/api/v1/members/${userId}/reinvite`,
      { method: "POST" }
    );
  },
  deactivateMember(userId: string) {
    return request<import("./types").User>(
      `/api/v1/members/${userId}/deactivate`,
      { method: "PATCH" }
    );
  },
  importMembers(file: File) {
    return uploadFile<ImportResult>("/api/v1/members/import", file);
  },

  // Visitors
  getVisitors(skip = 0, limit = 100, status?: string) {
    const params = new URLSearchParams({ skip: String(skip), limit: String(limit) });
    if (status) params.set("status", status);
    return request<import("./types").VisitorLog[]>(
      `/api/v1/visitors/?${params}`
    );
  },
  getPreApprovedVisitors() {
    return request<import("./types").VisitorLog[]>("/api/v1/visitors/pre-approved");
  },
  checkInVisitor(id: string) {
    return request<import("./types").VisitorLog>(
      `/api/v1/visitors/${id}/check-in`,
      { method: "PATCH" }
    );
  },
  checkOutVisitor(id: string) {
    return request<import("./types").VisitorLog>(
      `/api/v1/visitors/${id}/check-out`,
      { method: "PATCH" }
    );
  },

  // Complaints
  getComplaints(skip = 0, limit = 100) {
    return request<import("./types").Complaint[]>(
      `/api/v1/complaints/?skip=${skip}&limit=${limit}`
    );
  },
  updateComplaintStatus(id: string, status: string) {
    return request<import("./types").Complaint>(
      `/api/v1/complaints/${id}/status`,
      { method: "PATCH", body: JSON.stringify({ status }) }
    );
  },
};

export { ApiError };
