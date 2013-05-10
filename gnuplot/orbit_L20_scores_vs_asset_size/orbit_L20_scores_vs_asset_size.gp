stats "orbit_L20_scores_vs_asset_size.dat" using 1:2 nooutput
set term png
set output "/tmp/orbit_L20_scores_vs_asset_size.png"
set title "Orbit L20 scores vs. asset size [GB]" 
set xlabel "asset size [GB]" offset 0,-1
set ylabel "L20 score" offset 0,0
set cblabel "Bandwidth [Mbps]"
set xrange [0:1024]
set yrange [0:*]
set cbrange [0:4095]
set style fill solid 1.0
set xtics 0,100 nomirror rotate by -45
set ytics 0,500
set grid
set palette defined ( 0 "green", 511 "yellow", 3583 "red", 4095 "blue" )
xtot = 0
BtoGB(B) = B / (1024**3)
label(B) = sprintf("%s",sprintf("%.2f",BtoGB(B)))
total(w) = ( xtot = xtot + w, xtot - w)
set key title sprintf("Total size of assets: %.2f GB\nL20 min.: %d, L20 max.: %d",BtoGB(STATS_sum_y), STATS_min_x, STATS_max_x)
plot "orbit_L20_scores_vs_asset_size.dat" using (total(BtoGB($2))+(0.5*BtoGB($2))):1:(BtoGB($2)):($3) with boxes notitle linecolor palette
