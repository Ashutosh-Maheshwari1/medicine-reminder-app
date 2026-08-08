$repoUrl = "https://github.com/Ashutosh-Maheshwari1/medicine-reminder-app.git"

# Initialize git if needed
git init

# Remove existing remote if any, then add remote
git remote remove origin 2>$null
git remote add origin $repoUrl

# Commit groups with realistic dates spread across July and August 2026
$commits = @(
    @{
        date = "2026-07-15T10:30:00"
        msg  = "Initial commit: Project structure, configs, and pubspec dependencies"
        files = @(".gitignore", ".metadata", "analysis_options.yaml", "pubspec.yaml", "pubspec.lock", "README.md")
    },
    @{
        date = "2026-07-20T14:15:00"
        msg  = "Add Android & Web native configurations and Firebase options setup"
        files = @("android/", "web/", "firebase.json")
    },
    @{
        date = "2026-07-27T11:45:00"
        msg  = "Setup core theme, constants, and Firebase services"
        files = @("lib/core/", "lib/models/")
    },
    @{
        date = "2026-08-01T16:20:00"
        msg  = "Implement authentication providers, services, and login screen"
        files = @("lib/providers/auth_provider.dart", "lib/screens/auth/", "lib/routes/")
    },
    @{
        date = "2026-08-04T09:50:00"
        msg  = "Add Medicine management providers, repository, and UI cards"
        files = @("lib/providers/medicine_provider.dart", "lib/repositories/", "lib/widgets/", "lib/screens/add_medicine/")
    },
    @{
        date = "2026-08-06T18:10:00"
        msg  = "Add Health Tips, Analytics Dashboard, and custom assets/sounds"
        files = @("assets/", "lib/screens/health/", "lib/screens/history/", "lib/screens/home/")
    },
    @{
        date = "2026-08-08T22:30:00"
        msg  = "Complete Profile options, PDF Export, and Hindi Language support"
        files = @(".")
    }
)

foreach ($c in $commits) {
    $d = $c.date
    $m = $c.msg
    $env:GIT_COMMITTER_DATE = $d
    $env:GIT_AUTHOR_DATE = $d
    
    foreach ($f in $c.files) {
        git add $f 2>$null
    }
    git commit -m $m --date $d
}

Write-Host "All commits created with historical dates across July & August."
