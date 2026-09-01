using BPCM;
using System;
using System.Security.Cryptography;

/// <summary>
/// Used to Hash Passwords with Salt, and Compare Hashed Passwords
/// for use with AWS
/// </summary>
public class PasswordTools
{
    /// <summary>
    /// Should be at least as large as the HASH size
    /// </summary>
    public const int SaltByteSize = 32;
    /// <summary>
    /// Should match the size of the HASH function used
    /// which in this case is HMACSHA1, or 20
    /// </summary>
    public const int HashByteSize = 20;
    /// <summary>
    /// Generate Hashed Version of Password, with random salt
    /// </summary>
    /// <param name="password">entered password</param>
    /// <param name="salt">salt if applicable</param>
    /// <returns>Obj with Salt, and Hash</returns>
    public static PasswordObj HashPassword(string password, string salt = null)
    {
        // Generate hash with salt if provided, otherwise generate new one
        var rfc2898DeriveBytes = string.IsNullOrWhiteSpace(salt)
            ? new Rfc2898DeriveBytes(password, SaltByteSize)
            : new Rfc2898DeriveBytes(password, Convert.FromBase64String(salt));

        var passwordSalt = rfc2898DeriveBytes.Salt;
        var passwordHash = rfc2898DeriveBytes.GetBytes(HashByteSize);
        return new PasswordObj(passwordSalt, passwordHash);
    }
    /// <summary>
    /// Compare user entered password with Hashed Version from DB
    /// </summary>
    /// <param name="salt">salt for user</param>
    /// <param name="password">entered password</param>
    /// <param name="correctHash">hashed password from db</param>
    /// <returns>true If password hashes match</returns>
    public static bool ValidatePassword(string password, string correctHash)
    {
        //var hash = HashPassword(password, salt);
        return password == correctHash;
    }
    public class PasswordObj
    {
        private readonly string _salt;
        private readonly string _hash;
        public PasswordObj(byte[] salt, byte[] hash)
        {
            _salt = Convert.ToBase64String(salt);
            _hash = Convert.ToBase64String(hash);
        }
        // C# 4, can't use read only auto properties
        public string Salt
        {
            get { return _salt; }
        }

        public string Hash
        {
            get { return _hash; }
        }
    }
    public static void GetSaltAndHashForUser(string username)
    {
        var cmd = new UsanCommand("users", UsanCommandType.SELECT);

    }
}