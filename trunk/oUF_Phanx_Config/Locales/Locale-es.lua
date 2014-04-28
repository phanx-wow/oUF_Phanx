--[[--------------------------------------------------------------------
	oUF_Phanx
	Fully-featured PVE-oriented layout for oUF.
	Copyright (c) 2008-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	http://www.curse.com/addons/wow/ouf-phanx
------------------------------------------------------------------------
	Spanish localization
	Contributors: Akkorian, Phanx
----------------------------------------------------------------------]]

if not strmatch(GetLocale(), "^es") then return end
local _, private = ...
local L = private.L

L.AddAura = "Añadir aura"
L.AddAura_Desc = "Introduce el ID de un hechizo y pulse Intro."
L.AddAura_Invalid = "¡Eso no es un ID de hechizo válido!"
L.AddAura_Note = "Para encontrar el número de un hechizo, búsquelo en Wowhead.com, y copie el número en el URL."
L.AuraFilter0 = "Nunca lo muestran"
L.AuraFilter1 = "Siempre lo muestran"
L.AuraFilter2 = "Sólo la mía"
L.AuraFilter3 = "Sólo en las amigas"
L.AuraFilter4 = "Sólo en mí mismo"
L.Auras = "Auras"
L.Auras_Desc = "Añadir nuevos beneficios y perjuicios para mostrar, o cambiar cómo se filtran las auras predefinidos."
L.BorderColor = "Color de borde"
L.BorderColor_Desc = "Establecer el color por defecto para los bordes de los marcos."
L.BorderSize = "Tamaño de borde"
L.ColorClass = "Colorear por clase"
L.ColorCustom = "Usar color personalizado"
L.ColorHealth = "Colorear por salud"
L.ColorPower = "Colorear por tipo de poder"
L.Colors = "Colores"
L.Colors_Desc = "Estas opciones te permiten modificar los colores utilizados para las diferentes partes de los marcos."
L.CombatText = "Texto de combate"
L.CombatText_Desc = "Mostrar texto de daños, sanaciones y otros retroalimentaciones de combate en el marco para este unidad."
L.DeleteAura = "Eliminar aura"
L.DeleteAura_Desc = "Eliminar el filtro personalizado para este aura."
L.DruidManaBar = "Barra de maná en formas"
L.DruidManaBar_Desc = "Mostrar una barra de maná cuando estás en forma felina o de oso."
L.EclipseBar = "Barra de eclipse"
L.EclipseBar_Desc = "Mostrar una barra de eclipse sobre el marco de tu personaje."
L.EclipseBarIcons = "Iconos de eclipse"
L.EclipseBarIcons_Desc = "Mostrar iconos animados en cada extremo de la barra de eclipse."
L.FilterDebuffHighlight = "Sólo perjuicios disipables"
L.FilterDebuffHighlight_Desc = "Resaltar los marcos solamente para los perjuicios que puedes eliminar."
L.Font = "Fuente"
L.FrameHeight = "Talla básico de marcos"
L.FrameHeight_Desc = "Cambiar la talla básica de los marcos."
L.FrameWidth = "Anchura básico de marcos"
L.FrameWidth_Desc = "Cambiar la anchura básica de los marcos. Algunos marcos son proporcionalmente más anchos o más estrechos."
L.HealthBG = "Brillo de fondo de salud"
L.HealthBG_Desc = "Cambiar el brillo relativo del fondo de la barra de salud."
L.HealthColor = "Modo de coloración de salud"
L.HealthColor_Desc = "Establecer como están coloreadas las barras de salud."
L.HealthColorCustom = "Color personalizado de salud"
L.IgnoreOwnHeals = "Ignorar propias sanaciones"
L.IgnoreOwnHeals_Desc = "Mostrar sólo las sanaciones en curso de lanzamiento por otros."
L.MoreSettings = "Otras opciones"
L.MoreSettings_Desc = "Estas opciones no tendrán efecto hasta la próxima vez que te conectes o vuelvas a cargar la interfaz de usuario."
L.None = "Ninguno"
L.Options_Desc = "oUF_Phanx es un diseño para oUF, por Haste. Estas opciones te permiten modificar la configuración de oUF_Phanx."
L.Outline = "Perfil de fuente"
L.PowerBG = "Brillo de fondo de salud"
L.PowerBG_Desc = "Cambiar el brillo relativo del fondo de la barra de poder."
L.PowerColor = "Modo de coloración de poder"
L.PowerColor_Desc = "Establecer como están coloreadas las barras de poder."
L.PowerColorCustom = "Color personalizado de poder"
L.PowerHeight = "Talla de barra de poder"
L.PowerHeight_Desc = "Cambiar la talla de la barra de poder, como un porcentaje de la altura total del marco."
L.ReloadUI = "Recargar IU"
L.RuneBars = "Barras de runas"
L.RuneBars_Desc = "Mostrar barras de tiempo de reutilización para tus runas sobre el maro de tu personaje."
L.Shadow = "Sombra del texto"
--L.StaggerBar = "Show stagger bar"
--L.StaggerBar_Desc = "Show your staggered damage as a bar above the player frame."
L.Texture = "Textura"
L.Thick = "Grueso"
L.Thin = "Fino"
L.ThreatLevels = "Niveles de amenaza"
L.ThreatLevels_Desc = "Mostrar los niveles de amenaza en lugar del sólo agro."
L.TotemBars = "Barras de totems"
L.TotemBars_Desc = "Mostrar barras de tiempo para tus totems sobre el maro de tu personaje."

L.UnitSettings = "Unidades"
L.UnitSettings_Desc = "Cambiar la configuraciones de los marcos de unidad individuales."
L.Unit_Player = "Jugador"
L.Unit_Pet = "Mascota"
L.Unit_Target = "Objetivo"
L.Unit_TargetTarget = "Objetivo de objetivo"
L.Unit_Focus = "Foco"
L.Unit_FocusTarget = "Objetivo de foco"
L.Unit_Party = "Grupo"
L.Unit_PartyPet = "Mascotas de grupo"
L.Unit_Boss = "Jefes"
L.Unit_Arena = "Enemigos de arena"
L.Unit_ArenaPet = "Mascotas de arena"
L.Unit_Global = "Todas unidades"
L.EnableUnit = "Activar"
L.EnableUnit_Desc = "Es posible desactivar el marco de oUF Phanx de esta unidad, con el fin de usar el marco de la interfaz por defecto o un otro addon."
L.Width = "Anchura"
L.Width_Desc = "Establecer la anchura del marco de esta unidad con relación a la anchura básica del diseño."
L.Height = "Altura"
L.Height_Desc = "Establecer la altura del marco de esta unidad con relación a la altura básica del diseño."
L.Power = "Barra de poder"
L.Power_Desc = "Mostrar una barra de poder (maná, energia, etc.) en el marco de esta unidad."
L.Castbar = "Barra de lanzamiento"
L.Castbar_Desc = "Mostrar una barra de lanzamiento en el marco de esta unidad."
L.ClassFeatures = "Funciones de clase %s"
