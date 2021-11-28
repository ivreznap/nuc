#!/bin/bash
nuclei --update-templates --silent

read -p "Enter domain names seperated by 'space' : " input
for i in ${input[@]}
do

echo "
.
.
.
Scan started for $i
" | notify --silent

mkdir $i

subfinder -d $i | httpx >> $i/subdomains.txt >/dev/null

echo "subdomains saved at $i/subdomains.txt." | notify

nuclei -l $i/subdomains.txt -t cves/ -o $i/cves.txt
echo "Scan for CVES completed." | notify

nuclei -l $i/subdomains.txt -t default-logins/ -o $i/default-logins.txt
echo "Scan for default-logins completed." | notify

nuclei -l $i/subdomains.txt -t exposures/ -o $i/exposures.txt
echo "Scan for exposures completed." | notify


nuclei -l $i/subdomains.txt -t misconfiguration/ -o $i/misconfiguration.txt
echo "Scan for misconfigurations completed." | notify


nuclei -l $i/subdomains.txt -t takeovers/ -o $i/takeovers.txt
echo "Scan for takeovers completed." | notify


nuclei -l $i/subdomains.txt -t vulnerabilities/ -o $i/vulnerabilities.txt
echo "Scan for vulnerabilities completed." | notify

cd $i

grep -r "info" > info.txt | notify -data info.txt -bulk
grep -r "low" > low.txt | notify -data low.txt -bulk
grep -r "medium" > medium.txt | notify -data medium.txt -bulk
grep -r "high" > high.txt | notify -data high.txt -bulk
grep -r "critical" > critical.txt | notify -data critical.txt -bulk

echo "
.
.
.
Scan finished for $i
" | notify --silent
done
