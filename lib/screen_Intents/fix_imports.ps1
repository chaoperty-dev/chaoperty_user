$path = "d:\NEW\chaoperty_user\lib\screen_Intents\payment_subV2_InvAll.dart"
$content = Get-Content $path -Raw

# General fix for root-relative imports from screen_Intents
$content = $content.Replace("import '../../", "import '../")

# Fix local APIS-V2 import (it became ../APIS-V2, needs to be APIS-V2 or ./APIS-V2)
$content = $content.Replace("import '../APIS-V2/", "import 'APIS-V2/")

# Fix Style path (lib/Style doesn't exist, files are in lib/)
$content = $content.Replace("import '../Style/Translate.dart';", "import '../Translate.dart';")
$content = $content.Replace("import '../Style/colors.dart';", "import '../color.dart';")
# Man_PDF might be in lib/Man_PDF, so ../Man_PDF is correct.

# Add missing imports from original file
$importsToAdd = @"
import '../Model/GetTeNant_Model.dart';
import 'package:chaoperty_user/screen/buttonnavbar.dart';
"@

if (-not $content.Contains("GetTeNant_Model.dart")) {
    $content = $content.Replace("import 'dart:async';", "import 'dart:async';`r`n$importsToAdd")
}

# Fix garbled comment
$content = $content.Replace("// âœ… use only alias", "")

[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
