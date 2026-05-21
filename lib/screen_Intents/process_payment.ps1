$path = "d:\NEW\chaoperty_user\lib\screen_Intents\payment_subV2_InvAll.dart"
$lines = Get-Content $path
$newLines = @()

foreach ($line in $lines) {
    if ($line.StartsWith("// ")) {
        $line = $line.Substring(3)
    } elseif ($line.StartsWith("//")) {
        $line = $line.Substring(2)
    }
    $newLines += $line
}

$content = $newLines -join "`r`n"
$content = $content.Replace("PaymentIntentsInvPage", "paymentSubV2InvAll")
$content = $content.Replace("_PaymentIntentsInvPageState", "_paymentSubV2InvAllState")

$oldCtor = "const paymentSubV2InvAll({super.key});"
$newCtor = @"
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<TeNantModel>? teNantModel;
  final String? cuslang;
  final String? serPayment;
  final String? serptPayment;
  paymentSubV2InvAll({
    Key? key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
    this.teNantModel,
    this.cuslang,
    this.serPayment,
    this.serptPayment,
  }) : super(key: key);
"@

if ($content.Contains($oldCtor)) {
    $content = $content.Replace($oldCtor, $newCtor)
} else {
    Write-Output "Constructor not found exactly as expected, trying regex or ignoring..."
    # Attempt to just inject logic if not exact match, but let's verify later.
}

[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
