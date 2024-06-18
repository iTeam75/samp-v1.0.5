Ниже приводится более подробное объяснение функций проекта SAMP версии 1.0.5:

**Check WikiMe** : https://github.com/iTeam75/samp-v1.0.5/wiki#fitur
1. **Login dan Registrasi:**
   - Fitur ini memungkinkan pemain untuk membuat akun dan masuk ke dalam permainan.
   - Pengguna akan memasukkan informasi seperti nama pengguna dan kata sandi.
   - Data akun dapat disimpan dalam file teks atau database.
   - Berikut adalah contoh kode untuk sistem login dan registrasi:

     ```pawn
     // File: login_register.pwn

     // Fungsi untuk memeriksa apakah pengguna telah terdaftar
     public OnPlayerConnect(playerid)
     {
         if(!IsPlayerRegistered(playerid))
         {
             // Tampilkan dialog registrasi
             ShowRegistrationDialog(playerid);
         }
         else
         {
             // Tampilkan dialog login
             ShowLoginDialog(playerid);
         }
         return 1;
     }

     // Fungsi untuk memeriksa apakah pengguna telah terdaftar
     bool IsPlayerRegistered(playerid)
     {
         // Implementasi logika pengecekan di sini
         // Misalnya, cek database atau file teks
         return true; // Ganti dengan logika sesuai kebutuhan
     }

     // Fungsi untuk menampilkan dialog registrasi
     ShowRegistrationDialog(playerid)
     {
         // Implementasi tampilan dialog registrasi di sini
     }

     // Fungsi untuk menampilkan dialog login
     ShowLoginDialog(playerid)
     {
         // Implementasi tampilan dialog login di sini
     }
     ```

3. **Fitur Admin:**
   - Fitur ini diperuntukkan bagi administrator server.
   - Admin memiliki akses khusus untuk mengelola pemain, mengawasi aktivitas, dan mengambil tindakan tertentu.
   - Contoh tindakan admin termasuk mengeluarkan pemain, memberikan hukuman, atau mengubah pengaturan server.
   - Berikut adalah contoh kode untuk sistem admin:

     ```pawn
     // File: scar.pwn

     // Fungsi untuk memeriksa apakah pemain adalah admin
     bool IsPlayerAdmin(playerid)
     {
         // Implementasi logika pengecekan di sini
         // Misalnya, cek level admin atau ID pemain
         return true; // Ganti dengan logika sesuai kebutuhan
     }

     // Fungsi untuk mengeluarkan pemain dari server
     KickPlayer(playerid, reason[])
     {
         if(IsPlayerAdmin(playerid))
         {
             // Implementasi tindakan kick di sini
             // Misalnya, Kick(playerid, reason);
         }
         else
         {
             SendClientMessage(playerid, -1, "Anda bukan admin.");
         }
     }
     ```

Pastikan untuk mengimplementasikan fitur-fitur ini dengan baik dan mengikuti praktik keamanan yang baik. Semoga berhasil dengan proyek SAMP Anda! 🚗💨

---

---

## Credits

- **LNH ShiroNeko**: Kontributor utama dan pengembang inti proyek ini.
- **Baynnniq**: just share the results of them and Re-make This Gamemode.
- **Comunitas SAMP**: Terima kasih atas dukungan dan kontribusi dari seluruh anggota komunitas.

Kami menghargai kerja keras dan dedikasi dari semua orang yang terlibat dalam proyek ini.
