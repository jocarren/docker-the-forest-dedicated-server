FROM ubuntu:18.04

MAINTAINER Jonathan Carreño <jocarren@gmail.com>

ENV WINEPREFIX=/wine DEBIAN_FRONTEND=noninteractive PUID=0 PGID=0
ENV serverIP="0.0.0.0"
ENV serverSteamPort="8766"
ENV serverGamePort="27015"
ENV serverQueryPort="27016"
ENV serverName="docker-generated"
ENV serverPlayers="8"
ENV enableVAC="off"
ENV serverPassword=""
ENV serverPasswordAdmin=""
ENV serverSteamAccount="anonymous"
ENV serverAutoSaveInterval="30"
ENV difficulty="Normal"
ENV initType="Continue"
ENV slot="1"
ENV showLogs="off"
ENV serverContact="email@gmail.com"
ENV veganMode="off"
ENV vegetarianMode="off"
ENV resetHolesMode="off"
ENV treeRegrowMode="off"
ENV allowBuildingDestruction="on" 
ENV allowEnemiesCreativeMode="off"
ENV allowCheats="off"
ENV realisticPlayerDamage="off"
ENV saveFolderPath="/theforest/saves/"
ENV targetFpsIdle="0"
ENV targetFpsActive="0"

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y wget software-properties-common supervisor apt-transport-https xvfb winbind cabextract \
    && wget https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && rm winehq.key \
    && apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/ \
    && apt-get update \
    && apt-get install -y winehq-stable \
    && wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x ./winetricks \
    && WINEDLLOVERRIDES="mscoree,mshtml=" wineboot -u \
    && wineserver -w \
    && ./winetricks -q winhttp wsh57 vcrun6sp6

COPY . ./

RUN apt-get remove -y software-properties-common apt-transport-https cabextract \
    && rm -rf winetricks /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /usr/bin/steamcmdinstaller.sh /usr/bin/servermanager.sh /wrapper.sh

EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

VOLUME ["/theforest", "/steamcmd"]

RUN echo "serverIP 0.0.0.0 \
serverSteamPort 8766 \
serverGamePort 27015 \
serverQueryPort 27016 \
serverName jammsen-docker-generated \
serverPlayers 8 \
enableVAC off \
serverPassword \
serverPasswordAdmin \
serverSteamAccount \
serverAutoSaveInterval 30 \
difficulty Normal \
initType Continue \
slot 1 \
showLogs off \
serverContact email@gmail.com \
veganMode off \
vegetarianMode off \
resetHolesMode off \
treeRegrowMode off \
allowBuildingDestruction on \
allowEnemiesCreativeMode off \
allowCheats off \
realisticPlayerDamage off \
saveFolderPath \
targetFpsIdle 0 \
targetFpsActive 0 \" >> /theforest/config/config.cfg

CMD ["supervisord"]
