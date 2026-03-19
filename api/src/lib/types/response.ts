/**
 * API Response Types
 * Standardized response format for all API endpoints
 */

// Base response interface
interface BaseResponse {
  success: boolean;
  message: string;
}

// Success response - always has data, never has errors
export interface SuccessResponse<T> extends BaseResponse {
  success: true;
  data?: T;
  errors?: never;
}

// Error response - always has errors, never has data
export interface ErrorResponse<T> extends BaseResponse {
  success: false;
  data?: never;
  errors: T;
}

// Union type for all responses
export type ApiResponse<T, E = unknown> = SuccessResponse<T> | ErrorResponse<E>;

// Helper function to create success response
export function createSuccessResponse<T>(message: string, data?: T): SuccessResponse<T> {
  return {
    success: true,
    message,
    ...(data !== undefined && { data }),
  };
}

// Helper function to create error response
export function createErrorResponse<E>(message: string, errors: E): ErrorResponse<E> {
  return {
    success: false,
    message,
    errors,
  };
}
