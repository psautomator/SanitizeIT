@{
    # Configuration for the sanitization process
    Policy = @{
        # Threshold for automatic replacement
        AutoReplaceThreshold = 0.7
        # Threshold for flagging for review
        ReviewThreshold      = 0.4
    }

    # Definitions for sensitive data patterns
    Rules = @(
        # IPv4 Address
        @{
            Name        = "IPv4Address"
            Description = "Standard IPv4 Address"
            Type        = "Network"
            Pattern     = "\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
            Score       = 0.8
        },
        # Email Address
        @{
            Name        = "EmailAddress"
            Description = "Standard Email Address format"
            Type        = "Person"
            Pattern     = "\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b"
            Options     = "IgnoreCase"
            Score       = 0.9
        },
        # SID (Security Identifier)
        @{
            Name        = "ActiveDirectorySID"
            Description = "Windows Security Identifier (SID)"
            Type        = "Identity"
            Pattern     = "S-1-5-21-\d+-\d+-\d+-\d+"
            Score       = 0.95
        },
        # UNC Path
        @{
            Name        = "UNCPath"
            Description = "Windows Universal Naming Convention path"
            Type        = "Network"
            Pattern     = "\\\\[a-zA-Z0-9.-]+\\[a-zA-Z0-9$._-]+"
            Score       = 0.7
        },
        # FQDN / Hostname (Simplified)
        @{
            Name        = "Hostname"
            Description = "Internal Hostname or FQDN candidate"
            Type        = "Infrastructure"
            Pattern     = "\b[a-zA-Z0-9-]{3,63}(?:\.[a-zA-Z0-9-]{2,63})+\b"
            Score       = 0.5
        }
    )

    # Veldnaam-gebaseerde matches
    SchemaRules = @(
        @{ Pattern = "User*"; Score = 0.5; Type = "Person" },
        @{ Pattern = "Email*"; Score = 0.6; Type = "Person" },
        @{ Pattern = "Server*"; Score = 0.6; Type = "Infrastructure" },
        @{ Pattern = "Host*"; Score = 0.6; Type = "Infrastructure" },
        @{ Pattern = "IP*"; Score = 0.6; Type = "Network" },
        @{ Pattern = "*Password*"; Score = 1.0; Type = "Secret" },
        @{ Pattern = "DistinguishedName"; Score = 0.9; Type = "Identity" },
        @{ Pattern = "SamAccountName"; Score = 0.9; Type = "Identity" }
    )
}
