/**
 * Domain Entities
 * Representasi data dari database
 */

export interface IUser {
  id: string;
  email: string;
  name: string;
  last_login_at: Date | null;
  created_at: Date;
  updated_at: Date;
}
