namespace CRUD_Backend.Models.DTOs.Requests
{
    public class GetConfigsRequestDTO
    {
        public string UserName { get; set; } = string.Empty;
        public string? Application { get; set; }
        public string? Language { get; set; }
        public string? DNIS { get; set; }
        public string? DestinationPhoneNumber { get; set; }
        public string? Peg { get; set; }
        public string? Rank { get; set; }
        public string? OfferID { get; set; }
        public string? OfferType { get; set; }
        public string? LastModifiedBy { get; set; }
        public DateTime? LastModifiedDate { get; set; }
    }
}
