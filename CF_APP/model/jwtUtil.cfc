component {
    
    variables.secretKey = "your-super-secret-key-change-this-in-production-min-32-chars";
    variables.algorithm = "HS256";
    variables.tokenExpiry = 24; // hours
    
    public string function generateToken(required struct payload) {
        try {
            // Create header
            var header = {
                "alg" = variables.algorithm,
                "typ" = "JWT"
            };
            
            // Add expiry to payload
            var now = dateConvert("local2utc", now());
            var exp = dateAdd("h", variables.tokenExpiry, now);
            
            payload.iat = dateDiff("s", dateConvert("local2utc", "January 1 1970 00:00"), now);
            payload.exp = dateDiff("s", dateConvert("local2utc", "January 1 1970 00:00"), exp);
            
            // Encode header and payload
            var encodedHeader = base64UrlEncode(serializeJSON(header));
            var encodedPayload = base64UrlEncode(serializeJSON(payload));
            
            // Create signature
            var signature = createSignature(encodedHeader & "." & encodedPayload);
            
            // Return complete token
            return encodedHeader & "." & encodedPayload & "." & signature;
            
        } catch (any e) {
            throw(message="Error generating JWT token: " & e.message);
        }
    }
    
    public struct function verifyToken(required string token) {
        var result = {
            valid = false,
            payload = {},
            error = ""
        };
        
        try {
            // Split token into parts
            var parts = listToArray(token, ".");
            
            if (arrayLen(parts) != 3) {
                result.error = "Invalid token format";
                return result;
            }
            
            var encodedHeader = parts[1];
            var encodedPayload = parts[2];
            var signature = parts[3];
            
            // Verify signature
            var expectedSignature = createSignature(encodedHeader & "." & encodedPayload);
            
            if (signature != expectedSignature) {
                result.error = "Invalid signature";
                return result;
            }
            
            // Decode payload
            var payload = deserializeJSON(base64UrlDecode(encodedPayload));
            
            // Check expiry
            var now = dateDiff("s", dateConvert("local2utc", "January 1 1970 00:00"), dateConvert("local2utc", now()));
            
            if (structKeyExists(payload, "exp") && payload.exp < now) {
                result.error = "Token expired";
                return result;
            }
            
            result.valid = true;
            result.payload = payload;
            
        } catch (any e) {
            result.error = "Error verifying token: " & e.message;
        }
        
        return result;
    }
    
    private string function createSignature(required string data) {
        var key = charsetDecode(variables.secretKey, "utf-8");
        var message = charsetDecode(arguments.data, "utf-8");
        
        var mac = createObject("java", "javax.crypto.Mac").getInstance("HmacSHA256");
        var secretKey = createObject("java", "javax.crypto.spec.SecretKeySpec").init(key, "HmacSHA256");
        mac.init(secretKey);
        
        var signatureBytes = mac.doFinal(message);
        return base64UrlEncode(toBase64(signatureBytes));
    }
    
    private string function base64UrlEncode(required string input) {
        var encoded = toBase64(input);
        encoded = replace(encoded, "+", "-", "all");
        encoded = replace(encoded, "/", "_", "all");
        encoded = replace(encoded, "=", "", "all");
        return encoded;
    }
    
    private string function base64UrlDecode(required string input) {
        var decoded = arguments.input;
        decoded = replace(decoded, "-", "+", "all");
        decoded = replace(decoded, "_", "/", "all");
        
        // Add padding
        var padding = 4 - (len(decoded) mod 4);
        if (padding < 4) {
            decoded &= repeatString("=", padding);
        }
        
        return toString(toBinary(decoded));
    }
    
}