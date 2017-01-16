function New-AzureLab {
  [CmdletBinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]{1,61}")]
    [string]$ResourceGroup

  )
  # Set-up the relevant parameters to pass to the template

  # Deploy the template

  # Return a PSCustomObject that represents the end state of the objects deployed

}

