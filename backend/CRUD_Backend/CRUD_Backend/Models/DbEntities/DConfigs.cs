namespace CRUD_Backend.Models.DbEntities;

using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

[Serializable]
[Table("configurations", Schema = "crud")]
public class DConfigs
{
    [Key]
    [Column("crudId")]
    public int CrudId { get; set; }

    [Column("order")]
    public int Order { get; set; }

    [Column("applicationId")]
    public int ApplicationId { get; set; }

    [Column("application")]
    public string Application { get; set; }

    [Column("languageId")]
    public int? LanguageId { get; set; }

    [Column("language")]
    public string? Language { get; set; }

    [Column("dnis")]
    [MaxLength(32)]
    public string? Dnis { get; set; }

    [Column("destination")]
    [MaxLength(32)]
    public string? Destination { get; set; }

    [Column("rank")]
    [MaxLength(6)]
    public string? Rank { get; set; }

    [Column("offerId")]
    [MaxLength(8)]
    public string? OfferId { get; set; }

    [Column("offerType")]
    [MaxLength(128)]
    public string? OfferType { get; set; }

    [Column("peg")]
    [MaxLength(128)]
    public string? Peg { get; set; }

    [Column("skillId")]
    [MaxLength(16)]
    public string? SkillId { get; set; }

    [Column("skillName")]
    [MaxLength(64)]
    public string? SkillName { get; set; }

    [Column("agentsAvailable")]
    public int? AgentsAvailable { get; set; }

    [Column("med")]
    public int? Med { get; set; }

    [Column("overflowSkillId")]
    [MaxLength(16)]
    public string? OverflowSkillId { get; set; }

    [Column("overflowSkillName")]
    [MaxLength(64)]
    public string? OverflowSkillName { get; set; }

    [Column("overflowAgentsAvailable")]
    public int? OverflowAgentsAvailable { get; set; }

    [Column("overflowMed")]
    public int? OverflowMed { get; set; }

    [Column("lastModifiedUserId")]
    public int LastModifiedUserId { get; set; }

    [Column("lastModifiedUserName")]
    public string LastModifiedUserName { get; set; }

    [Column("lastModifiedDateTime")]
    public DateTime LastModifiedDateTime { get; set; }

    public DConfigs()
    {
    }
}

