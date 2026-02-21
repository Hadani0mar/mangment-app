using System;
using System.Windows.Forms;
using System.Drawing;
using System.IO;
using System.Diagnostics;

public class SmartInstaller : Form {
    private Label label;
    private Button btnInstall;
    private ProgressBar progressBar;

    public SmartInstaller() {
        this.Text = "مثبت النظام المالي الذكي - v1.2.5";
        this.Size = new Size(500, 300);
        this.FormBorderStyle = FormBorderStyle.FixedDialog;
        this.StartPosition = FormStartPosition.CenterScreen;
        this.MaximizeBox = false;
        this.RightToLeft = RightToLeft.Yes;
        this.Font = new Font("Segoe UI", 10);

        label = new Label() {
            Text = "مرحباً بك في مثبت النظام المالي.\nسيقوم هذا المعالج بتثبيت التطبيق وإنشاء اختصار على سطح المكتب.",
            Location = new Point(20, 30),
            Size = new Size(450, 60),
            TextAlign = ContentAlignment.MiddleCenter
        };

        btnInstall = new Button() {
            Text = "بدء التثبيت الآن",
            Location = new Point(150, 150),
            Size = new Size(200, 50),
            BackColor = Color.FromArgb(79, 70, 229),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat
        };
        btnInstall.Click += StartInstallation;

        progressBar = new ProgressBar() {
            Location = new Point(50, 110),
            Size = new Size(400, 20),
            Visible = false
        };

        this.Controls.Add(label);
        this.Controls.Add(btnInstall);
        this.Controls.Add(progressBar);
    }

    private void StartInstallation(object sender, EventArgs e) {
        btnInstall.Enabled = false;
        progressBar.Visible = true;
        progressBar.Value = 20;

        try {
            string currentDir = AppDomain.CurrentDomain.BaseDirectory;
            string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
            string exePath = Path.Combine(currentDir, "financial_system.exe");

            if (!File.Exists(exePath)) {
                // Check if it's in a subfolder like 'Release'
                string releasePath = Path.Combine(currentDir, "data"); 
                if (!File.Exists(exePath)) {
                    MessageBox.Show("يرجى التأكد من وجود ملف financial_system.exe في نفس المجلد.");
                    btnInstall.Enabled = true;
                    return;
                }
            }

            progressBar.Value = 60;

            // Create Shortcut using PowerShell (No COM dependencies needed)
            string shortcutTarget = exePath;
            string shortcutPath = Path.Combine(desktopPath, "النظام المالي.lnk");
            string iconPath = Path.Combine(currentDir, "assets", "app_icon.ico");
            if (!File.Exists(iconPath)) iconPath = exePath;

            string psCommand = "$s=(New-Object -COM WScript.Shell).CreateShortcut('" + shortcutPath + "');" +
                               "$s.TargetPath='" + shortcutTarget + "';" +
                               "$s.WorkingDirectory='" + currentDir + "';" +
                               "$s.IconLocation='" + iconPath + "';" +
                               "$s.Save()";

            ProcessStartInfo psi = new ProcessStartInfo("powershell", "-Command \"" + psCommand + "\"");
            psi.WindowStyle = ProcessWindowStyle.Hidden;
            Process.Start(psi).WaitForExit();

            progressBar.Value = 100;
            MessageBox.Show("تم التثبيت بنجاح! تم إنشاء اختصار على سطح المكتب باسم 'النظام المالي'.", "نجاح");
            Application.Exit();
        } catch (Exception ex) {
            MessageBox.Show("حدث خطأ أثناء التثبيت: " + ex.Message);
            btnInstall.Enabled = true;
        }
    }

    [STAThread]
    public static void Main() {
        Application.EnableVisualStyles();
        Application.Run(new SmartInstaller());
    }
}
