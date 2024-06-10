#include <a_samp>
#include <a_mysql>
#include "../include/gl_common.inc"
#include <crashdetect>

#define MYSQL_HOST    "51.81.57.217"      //Alamat IP dari Server MySQL
#define MYSQL_USER    "u2296840_2r6JVsfdZ9"           //Username untuk masuk
#define MYSQL_PASS    "5fP^j8uzbt3=PHPY04wVy.zk"               //Password untuk muser
#define MYSQL_DBSE    "s2296840_sto"       //Nama dari database

/*#define MYSQL_USER    "root"           //Username untuk masuk
#define MYSQL_PASS    ""               //Password untuk muser
#define MYSQL_DBSE    "testsamp"       //Nama dari database*/

new total_vehicles_from_files=0; 

new MySQL:handle; //Pegangan koneksi yang nantinya kita butuhkan untuk mengakses tabel

//Dialog IDs (Anda dapat mengubahnya jika sudah ada yang pakai)
#define DIALOG_REGISTER  2020
#define DIALOG_LOGIN     2021

enum pDataEnum
{
	p_id,
	bool:pLoggedIn,
	pName[MAX_PLAYER_NAME],
	Float:pHealth,Float:pArmour,
	Float:pPosX,Float:pPosY,Float:pPosZ,Float:pAngle,
	pVW,pInt,
	pSkin,
	pLevel,
	pMoney,
	pKills,
	pDeaths
}
new pInfo[MAX_PLAYERS][pDataEnum];


main()
{
	print("\n----------------------------------");
	print(" Basic GM Mysql R41-4");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText("Basic GM Mysql R41-4");
	MySQL_SetupConnection();

	// SPECIAL
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/trains.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/pilots.txt");

   	// LAS VENTURAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
    
    // SAN FIERRO
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
    
    // LOS SANTOS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
    
    // OTHER AREAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/bone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/flint.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/red_county.txt");

    printf("Total vehicles from files: %d",total_vehicles_from_files);

	return 1;
}

public OnGameModeExit()
{
	mysql_close(handle);
	return 1;
}

public OnPlayerConnect(playerid)
{
	resertenum(playerid);
	GetName(playerid);
	return 1;
}

public OnPlayerRequestClass(playerid)
{
	//Jika pemain memasuki PlayerRequestClass, kita memeriksa apakah dia sudah masuk
	if(!pInfo[playerid][pLoggedIn])
	{
		//Jika tidak, kita memeriksa apakah dia sudah memiliki akun
		//Kami mengirim kueri dan memanggil panggilan balik baru
		new query[128];
		mysql_format(handle, query, sizeof(query), "SELECT id FROM users WHERE name = '%e'", pInfo[playerid][pName]);
		mysql_pquery(handle, query, "OnUserCheck", "d", playerid);
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	if(!pInfo[playerid][pLoggedIn])
	{
		SendClientMessage(playerid, -1, "{FF0000}Anda harus masuk akun terlebih dahulu!");
		return 0;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_REGISTER)
	{
		//Jika Pemain memilih batal
		if(!response) return Kick(playerid);

		//Jika pemain tidak mengetik apa pun atau kata sandi singkat minimal 3 digit
		if(strlen(inputtext) < 3) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registrasi", "Silakan daftarkan diri Anda:\n{FF0000}Setidaknya 3 karakter!", "Masuk", "Batal");

		//Jika semuanya baik-baik saja, system memasukkan pengguna ke dalam database
		//Kami menyandikan kata sandi dengan hash MD5
		new query[256];
		mysql_format(handle, query, sizeof(query), "INSERT INTO users (name, password) VALUES ('%e', MD5('%e'))", pInfo[playerid][pName], inputtext);

		//Kueri dikirim dan system memanggil OnUserRegister
		mysql_pquery(handle, query, "OnUserRegister", "d", playerid);
		return 1;
	}
	if(dialogid == DIALOG_LOGIN)
	{
		//Jika Pemain memilih batal
		if(!response) return Kick(playerid);

		//Jika pemain tidak mengetik apa pun atau kata sandi singkat minimal 3 digit
		if(strlen(inputtext) < 3) return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Silahkan masuk ke akun anda:\n{FF0000}Setidaknya 3 karakter!", "Masuk", "Batal");

		//Jika semuanya baik-baik saja, system membaca dari database
		new query[256];
		mysql_format(handle, query, sizeof(query), "SELECT * FROM users WHERE name = '%e' AND password = MD5('%e')", pInfo[playerid][pName], inputtext);

		//Kueri dikirim dan system memanggil OnUserLogin
		mysql_pquery(handle, query, "OnUserLogin", "d", playerid);
		return 1;
	}
	return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
	//system menyimpan pemain saat dia meninggalkan server
	SaveUserStats(playerid);
	return 1;
}

forward OnUserCheck(playerid);
public OnUserCheck(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"Registrasi", "Silakan daftarkan diri Anda:", "Masuk", "Batal");
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Login", "Silahkan masuk ke akun anda:", "Masuk", "Batal");
	}
	return 1;
}

forward OnUserRegister(playerid);
public OnUserRegister(playerid)
{
	pInfo[playerid][p_id] = cache_insert_id();
	pInfo[playerid][pLoggedIn]  = true;
	SendClientMessage(playerid, -1, "[Account] Pendaftaran telah berhasil.");
	PlayerPlaySound(playerid, 1057 , 0.0, 0.0, 0.0);

	SetSpawnInfo(playerid, 0, 98, 1682.6084, -2327.8940, 13.5469, 3.4335, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	return 1;
}

forward OnUserLogin(playerid);
public OnUserLogin(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{
		//Pemain telah mengetik kata sandi yang salah
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Silahkan masuk ke akun anda:\n{FF0000}Kata sandi salah!", "Masuk", "Batal");
	}
	else
	{
		// Pemain telah mengetikkan kata sandi yang benar
 		cache_get_value_name_int(0, "id", pInfo[playerid][p_id]);
 		cache_get_value_name_float(0, "health", pInfo[playerid][pHealth]);
 		cache_get_value_name_float(0, "armour", pInfo[playerid][pArmour]);
 		cache_get_value_name_float(0, "posx", pInfo[playerid][pPosX]);
 		cache_get_value_name_float(0, "posy", pInfo[playerid][pPosY]);
 		cache_get_value_name_float(0, "posz", pInfo[playerid][pPosZ]);
 		cache_get_value_name_float(0, "angel", pInfo[playerid][pAngle]);
		cache_get_value_name_int(0, "interior", pInfo[playerid][pInt]);
		cache_get_value_name_int(0, "virtualworld", pInfo[playerid][pVW]);
		cache_get_value_name_int(0, "skin", pInfo[playerid][pSkin]);
		cache_get_value_name_int(0, "level", pInfo[playerid][pLevel]);
		cache_get_value_name_int(0, "money", pInfo[playerid][pMoney]);
		cache_get_value_name_int(0, "kills", pInfo[playerid][pKills]);
		cache_get_value_name_int(0, "deaths", pInfo[playerid][pDeaths]);
		pInfo[playerid][pLoggedIn]  = true;
		SendClientMessage(playerid, -1, "[Account] Masuk.");

		PlayerPlaySound(playerid, 1057 , 0.0, 0.0, 0.0);
		SetPlayerHealth(playerid, pInfo[playerid][pHealth]);
		SetPlayerArmour(playerid, pInfo[playerid][pArmour]);
		GivePlayerMoney(playerid, pInfo[playerid][pMoney]);
		SetSpawnInfo(playerid, -1, pInfo[playerid][pSkin], pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ], pInfo[playerid][pAngle], -1, -1, -1, -1, -1, -1);
		SpawnPlayer(playerid);
		SetPlayerInterior(playerid, pInfo[playerid][pInt]);
		SetPlayerVirtualWorld(playerid, pInfo[playerid][pVW]);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	//contoh kode saat mati
	if(killerid != INVALID_PLAYER_ID)
	{
		pInfo[killerid][pKills]++;
		GivePlayerMoney(killerid, 500); // bonus buat kill pemain lain
		pInfo[killerid][pMoney] += 10;
		if(pInfo[killerid][pKills] > 3)
		{
			pInfo[killerid][pLevel] = 1;
		}
	}
	pInfo[playerid][pDeaths]++;
	return 1;
}

stock SaveUserStats(playerid)
{
	//Jika pemain tidak masuk, system tidak menyimpan akunnya
	if(!pInfo[playerid][pLoggedIn]) return 1;

	GetPlayerHealth(playerid, pInfo[playerid][pHealth]);
	GetPlayerArmour(playerid, pInfo[playerid][pArmour]);
	GetPlayerPos(playerid, pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ]);
	GetPlayerFacingAngle(playerid, pInfo[playerid][pAngle]);
	pInfo[playerid][pMoney] = GetPlayerMoney(playerid);	
	pInfo[playerid][pInt] 	= GetPlayerInterior(playerid);
	pInfo[playerid][pVW] 	= GetPlayerVirtualWorld(playerid);
	pInfo[playerid][pSkin]	= GetPlayerSkin(playerid);

	//Jika dia memiliki akun, system menyimpannya
	new query[500];
	mysql_format(handle, query, sizeof(query), "UPDATE users SET health = '%f', armour = '%f', posx = '%f', posy = '%f', posz = '%f', angel = '%f', interior = '%d', virtualworld = '%d', skin = '%d', level = '%d', money = '%d', kills = '%d', deaths = '%d' WHERE id = '%d'",
		pInfo[playerid][pHealth], pInfo[playerid][pArmour], 
		pInfo[playerid][pPosX], pInfo[playerid][pPosY], pInfo[playerid][pPosZ], pInfo[playerid][pAngle],
		pInfo[playerid][pInt], pInfo[playerid][pVW], pInfo[playerid][pSkin],
		pInfo[playerid][pLevel], pInfo[playerid][pMoney], pInfo[playerid][pKills], pInfo[playerid][pDeaths],
		pInfo[playerid][p_id]);

	//print(query); cek debug

	//mengirim Query
	mysql_pquery(handle, query);
	return 1;
}

stock MySQL_SetupConnection(ttl = 3)
{
	print("[MySQL] Menghubungkan ke database...");

	handle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_DBSE);

	if(mysql_errno(handle) != 0)
	{
		if(ttl > 1)
		{
			//Kami mencoba lagi untuk terhubung ke database
			print("[MySQL] Sambungan ke database tidak berhasil.");
			printf("[MySQL] Coba lagi (TTL: %d).", ttl-1);
			return MySQL_SetupConnection(ttl-1);
		}
		else
		{
			//Batalkan dan tutup server
			print("[MySQL] Sambungan ke database tidak berhasil.");
			print("[MySQL] Silakan periksa Informasi Login MySQL.");
			print("[MySQL] Mematikan server");
			return SendRconCommand("exit");
		}
	}
	printf("[MySQL] Koneksi ke database berhasil! Menangani: %d", _:handle);
	return 1;
}

stock GetName(playerid)
{
	GetPlayerName(playerid, pInfo[playerid][pName], MAX_PLAYER_NAME);
	return pInfo[playerid][pName];
}

resertenum(playerid)
{
	pInfo[playerid][p_id]       = 0;
	pInfo[playerid][pLoggedIn]  = false;
	pInfo[playerid][pLevel]     = 0;
	pInfo[playerid][pMoney]     = 0;
	pInfo[playerid][pKills]     = 0;
	pInfo[playerid][pDeaths]    = 0;
	pInfo[playerid][pInt] 		= 0;
	pInfo[playerid][pVW] 		= 0;
	pInfo[playerid][pSkin]		= 0;
}