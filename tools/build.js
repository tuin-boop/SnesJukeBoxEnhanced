const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
process.chdir(root);
const text = fs.readFileSync('original/LANGUAGE.txt', 'utf8');
const rows = [...text.matchAll(/^JUKEBOX_(\d+)\s*=\s*"(.*)";/gm)];
const files = new Map(fs.readdirSync('original/music').map(x => [x.toLowerCase(), x]));
function field(s, name) {
  const clean = s.replace(/\\c(?:\[[^\]]+\]|.)/g, '').replace(/\\n/g, '\n');
  return (clean.match(new RegExp(name + ':\\s*([^\\n]*)'))?.[1] || '').trim().replace(/\s+/g, ' ');
}
const tracks = rows.map(m => ({id:+m[1], album:field(m[2],'Game'), title:field(m[2],'Song'), composer:field(m[2],'Composer'), genre:field(m[2],'Genre')}));
for (const t of tracks) {
  if (!files.has(`song${String(t.id).padStart(3,'0')}.spc`)) throw Error(`Missing audio ${t.id}`);
  if (!t.album || !t.title) throw Error(`Missing metadata ${t.id}`);
}
const albums = [...new Set(tracks.map(t => t.album))].sort((a,b)=>a.localeCompare(b));
tracks.forEach(t=>t.albumId=albums.indexOf(t.album));
const q = JSON.stringify;
let code = 'class SJCatalog : Object\n{\n';
for (const [name, values, type] of [ ['Title', tracks.map(t=>t.title),'String'], ['Composer',tracks.map(t=>t.composer),'String'], ['Genre',tracks.map(t=>t.genre),'String'], ['AlbumID',tracks.map(t=>t.albumId),'int'] ]) {
  code += `static ${type} ${name}(int id) { static const ${type} data[]={${values.map(q).join(',')}}; return data[clamp(id-1,0,973)]; }\n`;
}
code += `static String Album(int id) { static const String data[]={${albums.map(q).join(',')}}; return data[clamp(id,0,${albums.length-1})]; }\n`;
code += `const AlbumCount = ${albums.length};\nconst TrackCount = ${tracks.length};\n}\n`;
fs.mkdirSync('src/snesjukebox',{recursive:true});
fs.writeFileSync('src/snesjukebox/catalog.zs',code);
fs.mkdirSync('test',{recursive:true});
fs.writeFileSync('test/catalog.json',JSON.stringify({albums,tracks},null,2));
console.log(`${tracks.length} verified tracks in ${albums.length} albums.`);
