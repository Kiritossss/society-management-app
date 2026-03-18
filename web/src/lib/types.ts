export interface Society {
  id: string;
  name: string;
  address: string;
  contact_email: string;
  is_active: boolean;
  created_at: string;
}

export interface User {
  id: string;
  society_id: string;
  unit_id: string | null;
  email: string;
  full_name: string;
  role: "admin" | "committee" | "support_staff" | "member";
  is_active: boolean;
  is_activated: boolean;
  created_at: string;
}

export interface MemberInvite extends User {
  invite_token: string | null;
}

export interface TokenResponse {
  access_token: string;
  token_type: string;
  user: User;
}

export interface Unit {
  id: string;
  society_id: string;
  block_name: string | null;
  floor_number: string | null;
  unit_number: string;
  unit_type: string | null;
  area_sqft: number | null;
  is_occupied: boolean;
  created_at: string;
  updated_at: string;
}

export type VisitPurpose = "guest" | "delivery" | "cab" | "service" | "other";
export type VisitStatus = "pre_approved" | "pending" | "approved" | "denied" | "checked_in" | "checked_out";

export interface VisitorLog {
  id: string;
  society_id: string;
  unit_id: string | null;
  resident_id: string | null;
  visitor_name: string;
  visitor_phone: string | null;
  visitor_count: number;
  purpose: VisitPurpose;
  vehicle_number: string | null;
  notes: string | null;
  status: VisitStatus;
  pre_approved_by_id: string | null;
  checked_in_by_id: string | null;
  expected_at: string | null;
  checked_in_at: string | null;
  checked_out_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface Complaint {
  id: string;
  society_id: string;
  raised_by_id: string;
  title: string;
  description: string;
  category: "maintenance" | "noise" | "cleanliness" | "security" | "other";
  status: "open" | "in_progress" | "resolved" | "closed";
  image_url: string | null;
  resolved_at: string | null;
  created_at: string;
  updated_at: string;
}
