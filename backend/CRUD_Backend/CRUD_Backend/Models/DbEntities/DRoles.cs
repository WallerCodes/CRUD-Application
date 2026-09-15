namespace CRUD_Backend.Models.DbEntities;

using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

[Serializable]
[Table("roles", Schema = "crud")]
public class DRoles
{
    [Key]
    [Column("roleId")]
    public int RoleId { get; set; }

    [Column("name")]
    public string RoleName { get; set; }

    [Column("description")]
    public string Description { get; set; }

    [Column("dateAdded")]
    public DateTime DateAdded { get; set; }

    public DRoles()
    {
    }
}
