---
external help file: Get-Hello-help.xml
Module Name: Get-Hello
online version:
schema: 2.0.0
---

# New-DomainToSPOSite

## SYNOPSIS
This script will add the domain the the list of accepted domains on Azure, email the list of people on that domain and then set the specified SPO site to accept external users.

## SYNTAX

```
New-DomainToSPOSite [-ExternalExtension] <String> [-Users] <String[]> [-SPOSiteURL] <String[]>
 [<CommonParameters>]
```

## DESCRIPTION
A lot of companies will have vendors come in and they will want access to colaborate on Sharepoint Site or Azure resource.
This script automates that process

## EXAMPLES

### EXAMPLE 1
```
New-DomainToSPOSite -ExternalExtension vendor.com -Users "jon@vendor.com", "susie@vendor.com" -SPOSiteURL mySPOsite.mycompany.com
```

This will add vendor.com to the list of accepted domains, send and invite to Jon and Sustie from vendor.com to access Azure and then allow them access to mySPOsite.mycompany.com

## PARAMETERS

### -ExternalExtension
The extension of the domain we need to add EX: outlook.com

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Users
A list of users to send the invites to

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SPOSiteURL
The full URL to the sharepoint site

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
