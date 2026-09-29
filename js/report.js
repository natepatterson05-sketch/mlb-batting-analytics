document.head.insertAdjacentHTML('beforeend','<link rel="stylesheet" href="css/baseball.css">');
const colors={navy:'#102b4e',red:'#d64b32',gold:'#e8ad37',teal:'#147d7e',grid:'rgba(16,43,78,.12)'};
Chart.defaults.font.family='Source Sans 3';Chart.defaults.color='#334155';
const base={responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{grid:{display:false}},y:{grid:{color:colors.grid},beginAtZero:true}}};
const make=(id,type,labels,datasets,options={})=>new Chart(document.getElementById(id),{type,data:{labels,datasets},options:{...base,...options,plugins:{...base.plugins,...options.plugins},scales:{...base.scales,...options.scales}}});
fetch('data/report.json').then(r=>r.json()).then(d=>{
 const dec=d.decadeRates;
 make('chart-power','line',dec.map(x=>x.decade),[{label:'HR per 100 AB',data:dec.map(x=>x.homeRunsPer100Ab),borderColor:colors.red,backgroundColor:colors.red,tension:.25,pointRadius:4}],{plugins:{legend:{display:true}}});
 make('chart-discipline','line',dec.map(x=>x.decade),[{label:'Strikeouts',data:dec.map(x=>x.strikeoutsPer100Ab),borderColor:colors.navy,tension:.25},{label:'Walks',data:dec.map(x=>x.walksPer100Ab),borderColor:colors.gold,tension:.25}],{plugins:{legend:{display:true}}});
 make('chart-average','bar',dec.map(x=>x.decade),[{label:'Batting average',data:dec.map(x=>x.battingAverage),backgroundColor:colors.teal}],{scales:{y:{min:.2,max:.3,grid:{color:colors.grid}}}});
 make('chart-seasons','bar',d.homeRunSeasons.map(x=>x.year),[{label:'Home runs',data:d.homeRunSeasons.map(x=>x.homeRuns),backgroundColor:d.homeRunSeasons.map((_,i)=>i===0?colors.red:colors.gold)}]);
 const horizontal=(id,items,label,key,color)=>make(id,'bar',items.map(x=>x[label]).reverse(),[{data:items.map(x=>x[key]).reverse(),backgroundColor:color}],{indexAxis:'y'});
 horizontal('chart-career-hr',d.careerHomeRuns,'playerName','homeRuns',colors.red);
 horizontal('chart-career-avg',d.careerAverage,'playerName','battingAverage',colors.teal);
 horizontal('chart-steals',d.careerSteals,'playerName','stolenBases',colors.gold);
 horizontal('chart-teams',d.teamHomeRuns.map(x=>({...x,label:`${x.year} ${x.teamName}`})),'label','homeRuns',colors.navy);
}).catch(err=>document.querySelectorAll('.chart-card').forEach(el=>el.innerHTML=`<p>Chart data could not load: ${err.message}</p>`));
