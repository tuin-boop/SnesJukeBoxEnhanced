class SJMenu : OptionMenu
{
 int tab,row,album,pressed,ticks;
 bool tabs,tracksView;
 double scale,ox,oy;
 Array<int> items;
 OptionMenuItemControl bindItem;
 static const String tabNames[]={"PLAYER","ALBUMS","FAVORITES","SETTINGS","KEYS"};
 static const String commands[]={"openmenu SJMenu","nextsong","prevsong","origsong","event sj_favorite","event sj_stop"};
 static const String controls[]={"OPEN JUKEBOX","NEXT SONG","PREVIOUS SONG","MAP MUSIC","FAVORITE CURRENT","STOP MUSIC"};
 override void Init(Menu parent,OptionMenuDescriptor desc)
 {Super.Init(parent,desc);tabs=true;pressed=-1;album=clamp(SJPlayer.CV("sj_album"),0,SJCatalog.AlbumCount-1);Rebuild();}
 override void Ticker(){Super.Ticker();ticks++;}
 void Rebuild()
 {
  items.Clear();
  for(int i=1;i<=SJCatalog.TrackCount;i++)if(tab==2?SJPlayer.Favorite(i):SJCatalog.AlbumID(i)==album)items.Push(i);
 }
 int Count(){return tab==0?8:tab==1?(tracksView?int(items.Size())+2:SJCatalog.AlbumCount):tab==2?max(1,int(items.Size())):tab==3?9:6;}
 void Layout(){scale=min((screen.GetWidth()-16)/800.,(screen.GetHeight()-16)/560.);ox=(screen.GetWidth()-800*scale)/2;oy=(screen.GetHeight()-560*scale)/2;}
 void Box(int x,int y,int w,int h,int color,double alpha=1.){screen.Dim(color,alpha,int(ox+x*scale),int(oy+y*scale),int(w*scale),int(h*scale));}
 void Text(int x,int y,String s,int color=Font.CR_WHITE,double size=1.4,int width=744)
 {
  Font f=Font.GetFont('SJFONT');
  while(f.StringWidth(s)*size>width && s.Length()>4)s=s.Left(s.Length()-4).."...";
  screen.DrawText(f,color,ox+x*scale,oy+y*scale,s,DTA_ScaleX,size*scale,DTA_ScaleY,size*scale);
 }
 void Card(int y,String label,String value,bool selected)
 {
  Box(26,y,748,33,selected?0x363451:0x181d33);
  if(selected)Box(26,y,3,33,0xf3bf72);
  Text(40,y+10,label,selected?Font.CR_GOLD:Font.CR_WHITE,1.25,value==""?710:390);
  if(value!="")Text(445,y+10,value,Font.CR_LIGHTBLUE,1.2,312);
 }
 String Mode(){int m=clamp(SJPlayer.CV("sj_mode"),0,2);return m==0?"SHUFFLE":m==1?"IN ORDER":"REPEAT TRACK";}
 String Scope(){int s=clamp(SJPlayer.CV("sj_scope"),0,2);return s==0?"ALL 974 TRACKS":s==1?"SELECTED ALBUM":"FAVORITES";}
 void Cycle(String name,int n,int d){SJPlayer.Set(name,(clamp(SJPlayer.CV(name),0,n-1)+d+n)%n);}
 void Change(int direction=1)
 {
  let p=SJPlayer.Get();if(!p)return;
  if(tab==0)
  {
   if(row==0)p.Next();else if(row==1)p.Next(-1);else if(row==2){if(p.current>0)p.PlayTrack(p.current);else p.Next();}
   else if(row==3)p.ToggleFavorite(p.current);else if(row==4)p.RestoreMapMusic();else if(row==5)p.StopPlayback();
   else if(row==6)Cycle("sj_mode",3,direction);else Cycle("sj_scope",3,direction);
  }
  else if(tab==1)
  {
   if(!tracksView){album=row;tracksView=true;row=0;Rebuild();}
   else if(row==0){p.PlayAlbum(album);}
   else if(row==1){tracksView=false;row=album;}
   else if(row-2<int(items.Size())){SJPlayer.Set("sj_scope",1);SJPlayer.Set("sj_album",album);p.PlayTrack(items[row-2]);}
  }
  else if(tab==2){if(items.Size()>0)p.PlayTrack(items[row]);}
  else if(tab==3)
  {
   if(row==0)Cycle("nomusic",2,direction);
   else if(row==1)Cycle("sj_mapchange",3,direction);
   else if(row==2)Cycle("sj_mode",3,direction);
   else if(row==3)Cycle("sj_scope",3,direction);
   else if(row==4)
   {static const int intervals[]={-1,30,60,90,120,180,300,600,900};int pos=4;for(int i=0;i<9;i++)if(intervals[i]==SJPlayer.CV("sj_interval"))pos=i;SJPlayer.Set("sj_interval",intervals[(pos+direction+9)%9]);}
   else if(row==5)Cycle("noinfo",2,direction);
   else if(row==6)Cycle("sj_hud",2,direction);
   else if(row==7)Cycle("sj_sfx",2,direction);
   else {let cv=CVar.FindCVar('snd_musicvolume');cv.SetFloat(clamp(cv.GetFloat()+direction*.05,0.,1.));}
  }
  else {bindItem=new('OptionMenuItemControl');bindItem.Init(controls[row],Name(commands[row]));bindItem.Activate();}
  MenuSound("menu/change");
 }
 override void Drawer()
 {
  Layout();let p=SJPlayer.Get();
  Box(0,0,800,560,0x0b0e1d);Box(0,0,800,4,0xa68bf0);
  Text(26,20,"SNES JUKEBOX",Font.CR_GOLD,2.6);
  Text(530,27,"ULTRAPACK / ALBUM EDITION",Font.CR_LIGHTBLUE,1.1,244);
  Text(26,55,String.Format("974 TRACKS   /   %d GAME ALBUMS   /   YOUR 16-BIT COLLECTION",SJCatalog.AlbumCount),Font.CR_LIGHTBLUE,1.1);
  for(int i=0;i<5;i++){Box(26+i*151,79,144,30,tab==i?0x504366:0x1c233b);Text(36+i*151,88,tabNames[i],tab==i?Font.CR_GOLD:Font.CR_WHITE,1.15,125);}
  Box(26,120,748,106,0x171d32);
  Text(40,131,p && p.active?"NOW PLAYING":"READY WHEN YOU ARE",Font.CR_LIGHTBLUE,1.0);
  if(p && p.current>0)
  {
   Text(40,151,String.Format("%03d  %s%s",p.current,SJCatalog.Title(p.current),SJPlayer.Favorite(p.current)?"  [FAV]":""),Font.CR_GOLD,1.65,712);
   Text(40,177,SJCatalog.Album(SJCatalog.AlbumID(p.current)),Font.CR_WHITE,1.2,712);
   Text(40,201,SJCatalog.Composer(p.current),Font.CR_LIGHTBLUE,1.0,470);
   Text(560,201,String.Format("%02d:%02d / %s",p.elapsed/2100,(p.elapsed/35)%60,p.active?Mode():p.status),Font.CR_LIGHTBLUE,1.,200);
  }
  else {Text(40,155,"PICK AN ALBUM. PRESS PLAY.",Font.CR_GOLD,1.8);Text(40,189,"Original SPC music, original track numbers.",Font.CR_WHITE,1.2);}
  int first=(row/6)*6;
  String heading=tab==0?"PLAYBACK":tab==1?(tracksView?SJCatalog.Album(album):"ALBUM LIBRARY / A-Z"):tab==2?"YOUR FAVORITES":tab==3?"LISTEN YOUR WAY":"KEY BINDINGS";
  Text(26,238,heading,Font.CR_LIGHTBLUE,1.05,610);
  Text(653,238,String.Format("%d / %d",first/6+1,(Count()+5)/6),Font.CR_GOLD,1.05,115);
  for(int i=first;i<min(Count(),first+6);i++)
  {
   String label="",value="";
   if(tab==0)
   {static const String names[]={"NEXT SONG","PREVIOUS SONG (IN ORDER)","RESTART CURRENT TRACK","FAVORITE / UNFAVORITE CURRENT","RESTORE MAP MUSIC","STOP MUSIC","PLAYBACK MODE","PLAY FROM"};label=names[i];if(i==6)value=Mode();if(i==7)value=Scope();}
   else if(tab==1 && !tracksView)
   {label=SJCatalog.Album(i);int n=0;for(int j=1;j<=974;j++)if(SJCatalog.AlbumID(j)==i)n++;label=label..String.Format("  (%d)",n);}
   else if(tab==1 && i<2){label=i==0?"PLAY THIS ALBUM / SET ALBUM SCOPE":"< BACK TO ALL ALBUMS";}
   else if(tab==1 || tab==2)
   {
    if(items.Size()==0)label="NO FAVORITES YET - FAVORITE A SONG IN PLAYER";
    else {int id=items[tab==1?i-2:i];label=String.Format("%03d  %s%s",id,SJCatalog.Title(id),SJPlayer.Favorite(id)?"  [FAV]":"");}
   }
   else if(tab==3)
   {
    static const String labels[]={"AUTOPLAY ON MAP ENTRY","ON MAP CHANGE","PLAYBACK MODE","PLAY FROM","AUTO-ADVANCE TIMER","TRACK NOTIFICATIONS","PERSISTENT NOW-PLAYING HUD","TRACK SWITCH SOUND","MUSIC VOLUME"};label=labels[i];
    if(i==0)value=SJPlayer.CV("nomusic")?"OFF":"ON";
    else if(i==1){int b=SJPlayer.CV("sj_mapchange");value=b==0?"NEXT SONG":b==1?"SAME TRACK (RESTART)":"MAP MUSIC";}
    else if(i==2)value=Mode();else if(i==3)value=Scope();
    else if(i==4)value=SJPlayer.CV("sj_mode")==2?"REPEAT MODE / TRACK LOOPS":SJPlayer.CV("sj_interval")<0?"OFF / TRACK LOOPS":String.Format("%d SECONDS",SJPlayer.AdvanceSeconds());
    else if(i==5)value=SJPlayer.CV("noinfo")?"OFF":"ON";
    else if(i==6)value=SJPlayer.CV("sj_hud")?"ON":"OFF";
    else if(i==7)value=SJPlayer.CV("sj_sfx")?"ON":"OFF";
    else value=String.Format("%d%%",int(CVar.FindCVar('snd_musicvolume').GetFloat()*100+.5));
   }
   else {label=controls[i];Array<int> keys;Bindings.GetAllKeysForCommand(keys,commands[i]);value=KeyBindings.NameAllKeys(keys,false);if(value=="")value="UNBOUND";if(bindItem && bindItem.mWaiting && row==i)value="PRESS A KEY...";}
   Card(258+(i-first)*36,label,value,!tabs && row==i);
  }
  Box(26,479,112,27,0x252b43);Text(39,487,"< PAGE",Font.CR_GOLD,1.1,95);
  Box(662,479,112,27,0x252b43);Text(677,487,"PAGE >",Font.CR_GOLD,1.1,90);
  Text(154,487,p?p.status:"",Font.CR_LIGHTBLUE,1.05,492);
  Text(26,518,tabs?"LEFT / RIGHT: TAB   ENTER / DOWN: BROWSE   ESC: CLOSE":"UP / DOWN: SELECT   ENTER: PLAY / CHANGE   PGUP / PGDN: PAGE",Font.CR_WHITE,1.05);
  Text(26,539,(tab==1 && tracksView)||tab==2?"BACKSPACE: FAVORITE TRACK   ESC: BACK   MOUSE: CLICK TO SELECT":"UP AT FIRST ROW: TABS   LEFT / RIGHT: CHANGE VALUE   ESC: BACK",Font.CR_LIGHTBLUE,1.0);
 }
 void Page(int d){row=clamp(row+d*6,0,Count()-1);tabs=false;}
 override bool MenuEvent(int key,bool controller)
 {
  if(bindItem && (key==MKEY_Input || key==MKEY_Abort))return bindItem.MenuEvent(key,controller);
  if(key==MKEY_Back){if(tracksView && tab==1){tracksView=false;row=album;return true;}return Super.MenuEvent(key,controller);}
  if(key==MKEY_PageUp || key==MKEY_PageDown){Page(key==MKEY_PageUp?-1:1);return true;}
  if(tabs)
  {
   if(key==MKEY_Left || key==MKEY_Right){tab=(tab+(key==MKEY_Left?4:1))%5;row=0;Rebuild();return true;}
   if(key==MKEY_Down || key==MKEY_Enter){tabs=false;return true;}return false;
  }
  if(key==MKEY_Up && row==0){tabs=true;return true;}
  if(key==MKEY_Up || key==MKEY_Down){row=clamp(row+(key==MKEY_Up?-1:1),0,Count()-1);return true;}
  if(key==MKEY_Clear)
  {
   if(tab==4)Bindings.UnbindACommand(commands[row]);
   else if(((tab==1 && tracksView && row>=2)||tab==2) && items.Size()>0){SJPlayer.Get().ToggleFavorite(items[tab==1?row-2:row]);Rebuild();row=min(row,Count()-1);}
   return true;
  }
  if(key==MKEY_Enter){Change();return true;}
  if((key==MKEY_Left || key==MKEY_Right) && (tab==3 || (tab==0 && row>=6))){Change(key==MKEY_Left?-1:1);return true;}
  return false;
 }
 override bool MouseEvent(int type,int x,int y)
 {
  if(bindItem && bindItem.mWaiting)return Super.MouseEvent(type,x,y);
  Layout();double mx=(x-ox)/scale,my=(y-oy)/scale;int hit=-1;
  if(mx>=26 && mx<774 && my>=79 && my<109){int t=int((mx-26)/151);if(t<5)hit=100+t;}
  else if(mx>=26 && mx<774 && my>=258 && my<474){int r=(row/6)*6+int((my-258)/36);if(r<Count())hit=r;}
  else if(my>=479 && my<506){if(mx>=26 && mx<138)hit=200;else if(mx>=662 && mx<774)hit=201;}
  if(type==MOUSE_Click)pressed=hit;
  if(type==MOUSE_Release)
  {
   if(hit>=0 && hit==pressed){if(hit>=200)Page(hit==200?-1:1);else if(hit>=100){tab=hit-100;row=0;tabs=true;Rebuild();}else{row=hit;tabs=false;Change();}}
   pressed=-1;
  }
  return true;
 }
}
