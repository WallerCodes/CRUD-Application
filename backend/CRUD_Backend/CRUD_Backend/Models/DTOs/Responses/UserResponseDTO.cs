using System.ComponentModel.DataAnnotations.Schema;

namespace CRUD_Backend.Models.DTOs.Responses
{
    public class UserResponseDTO
    {
        public int UserId { get; set; }

        public string? Username { get; set; }

        public bool IsDeleted { get; set; }

        public bool IsDisabled { get; set; }

        public bool IsSuperAdmin { get; set; }

        public bool IsUsanUser { get; set; }

        public bool IsLocked { get; set; }

        public short FailedLoginAttempts { get; set; }

        public bool ForceChangePassword { get; set; }

        public DateTime? LastLoginDate { get; set; }

        public DateTime? LastPasswordChangeDate { get; set; }

        public DateTime? DateAdded { get; set; }

        public List<ObjectUserRole> UserRoles { get; set; }

        public bool Success { get; set; } // was the user action successful or not

        public string? Reason { get; set; }
    }
}
