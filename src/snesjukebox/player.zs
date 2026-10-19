// Local music controller. No actors, inventory, or network commands are changed.
class SJPlayer : StaticEventHandler
{
 ui int current, elapsed, notice, lastMapTic;
 ui String lastMap, defaultMusic, status;
 ui bool active, wasLevel;
 static ui SJPlayer Get() { return SJPlayer(StaticEventHandler.Find('SJPlayer')); }
 static ui int CV(String key) { return CVar.FindCVar(key).GetInt(); }
 static ui void Set(String key,int value) { CVar.FindCVar(key).SetInt(value); }
 static ui bool Favorite(int id) { return CVar.FindCVar('sj_favorites').GetString().IndexOf(String.Format("|%d|",id))>=0; }
 ui void ToggleFavorite(int id)
 {
  if(id<1 || id>SJCatalog.TrackCount)return;
  let c=CVar.FindCVar('sj_favorites');String s=c.GetString(), token=String.Format("|%d|",id);
  if(Favorite(id))s.Replace(token,"");else s=s..token;
  c.SetString(s);status=Favorite(id)?"ADDED TO FAVORITES":"REMOVED FROM FAVORITES";
 }
 ui void PlayTrack(int id, bool effect=true)
 {
  if(id<1 || id>SJCatalog.TrackCount){status="TRACK NUMBER MUST BE 1 TO 974";return;}
  // Changing to the already playing lump does not rewind it in the engine.
  if(active && current==id)S_ChangeMusic("SILENCE",0,true,true);
  if(!S_ChangeMusic(String.Format("Song%03d",id),0,true,true)){status="COULD NOT START TRACK";return;}
  current=id;active=true;elapsed=0;notice=175;status="PLAYING";
  if(effect && CV("sj_sfx"))S_StartSound("music/shift",CHAN_AUTO,0,0.45,ATTN_NONE);
 }
 ui bool Eligible(int id)
 {
  int scope=clamp(CV("sj_scope"),0,2);
  return scope==0 || (scope==1 && SJCatalog.AlbumID(id)==clamp(CV("sj_album"),0,SJCatalog.AlbumCount-1)) || (scope==2 && Favorite(id));
 }
 ui int Roll(int count)
 {
  return Random(0,max(1,count)-1);
 }
 static ui int AdvanceSeconds()
 {
  // v1.1 profiles saved zero (formerly off). Give them working autoplay too.
  // Minus one is the explicit off setting; repeat mode loops without rewinding.
  if(CV("sj_mode")==2 || CV("sj_interval")<0)return 0;
  int seconds=clamp(CV("sj_interval"),0,900);
  return seconds==0?120:seconds;
 }
 ui void PlayAlbum(int album)
 {
  Set("sj_album",clamp(album,0,SJCatalog.AlbumCount-1));Set("sj_scope",1);
  if(CV("sj_mode")==0){Next();return;}
  for(int id=1;id<=SJCatalog.TrackCount;id++)if(Eligible(id)){PlayTrack(id);return;}
 }
 ui void Next(int direction=1,bool automatic=false)
 {
  Array<int> pool;
  for(int i=1;i<=SJCatalog.TrackCount;i++)if(Eligible(i))pool.Push(i);
  if(pool.Size()==0){status="NO FAVORITES YET - ADD A TRACK FIRST";return;}
  int mode=clamp(CV("sj_mode"),0,2);
  if(automatic && mode==2 && current>0){PlayTrack(current,false);return;}
  if(mode==0 && direction>0)
  {
   int pick=Roll(pool.Size());
   if(pool.Size()>1 && pool[pick]==current)pick=(pick+1+Roll(pool.Size()-1))%pool.Size();
   PlayTrack(pool[pick]);return;
  }
  int pos=-1;
  for(int i=0;i<int(pool.Size());i++)if(pool[i]==current){pos=i;break;}
  if(pos<0)pos=direction>0?-1:0;
  int count=int(pool.Size());
  PlayTrack(pool[(pos+direction+count)%count]);
 }
 ui void RestoreMapMusic()
 {
  if(defaultMusic!="")S_ChangeMusic(defaultMusic,0,true,true);else S_ChangeMusic("*",0,true,true);
  active=false;status="MAP MUSIC";notice=0;
 }
 ui void StopPlayback() { S_ChangeMusic("SILENCE",0,true,true);active=false;status="STOPPED";notice=0; }
 override void ConsoleProcess(ConsoleEvent e)
 {
  if(e.Name=="sj_next")Next();
  else if(e.Name=="sj_prev")Next(-1);
  else if(e.Name=="sj_default")RestoreMapMusic();
  else if(e.Name=="sj_play")PlayTrack(e.Args[0]);
  else if(e.Name=="sj_stop")StopPlayback();
  else if(e.Name=="sj_favorite")ToggleFavorite(current);
 }
 override void UiTick()
 {
  bool inLevel=gamestate==GS_LEVEL;
  if(!inLevel){wasLevel=false;return;}
  bool changed=!wasLevel || lastMap!=level.MapName || level.maptime<lastMapTic;
  wasLevel=true;lastMap=level.MapName;lastMapTic=level.maptime;
  if(changed)
  {
   defaultMusic=level.Music;
   int behavior=clamp(CV("sj_mapchange"),0,2);
   if(!CV("nomusic") && behavior!=2)
   {
    if(behavior==1 && current>0)PlayTrack(current,false);else Next();
   }
   else {active=false;status="MAP MUSIC";}
  }
  if(notice>0)notice--;
  if(active)
  {
   elapsed++;
   int seconds=AdvanceSeconds();
   if(seconds>0 && elapsed>=seconds*35)Next(1,true);
  }
 }
 override void RenderOverlay(RenderEvent e)
 {
  if(!active || current<1 || CV("noinfo") || (!CV("sj_hud") && notice<=0) || menuactive!=Menu.Off)return;
  double scale=max(1.,min(screen.GetWidth()/640.,screen.GetHeight()/400.));
  String s=String.Format("%03d  %s",current,SJCatalog.Title(current));
  Font f=Font.GetFont('SJFONT');
  while(f.StringWidth(s)*scale>screen.GetWidth()-32 && s.Length()>5)s=s.Left(s.Length()-4).."...";
  int w=min(screen.GetWidth()-16,int(f.StringWidth(s)*scale)+24);
  screen.Dim(0x0c1023,.85,8,12,w,int(32*scale));
  screen.DrawText(f,Font.CR_GOLD,16,16,s,DTA_ScaleX,scale,DTA_ScaleY,scale);
  String album=SJCatalog.Album(SJCatalog.AlbumID(current));
  while(f.StringWidth(album)*scale>w-16 && album.Length()>5)album=album.Left(album.Length()-4).."...";
  screen.DrawText(f,Font.CR_LIGHTBLUE,16,16+14*scale,album,DTA_ScaleX,scale,DTA_ScaleY,scale);
 }
}
