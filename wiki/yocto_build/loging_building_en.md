### Build Logging

If you simply redirect console output to a file,  
you won’t capture the exact duration of signature checking.  

For example, in the console the message looks like:  
`Checking sstate mirror object availability: 100% |#######################################| Time: 0:00:14`  

But in a text file redirected from standard output, it appears as:  
`Checking sstate mirror object availability...done.`

### Solution: Use the `script` Utility

To log accurately, use `script`.  
Example command:
```bash
script -c "bitbake core-image-minimal" out_file_name.txt
```

The `-c` flag passes the command to be logged.

All output goes to `out_file_name.txt`.  
To extract the signature check time:
```bash
cat out_file_name.txt | grep "Checking sstate"
```

Sample output:
```bash
Checking sstate mirror object availability: 100% |########################| Time: 0:00:14
```

To extract just the time from that line:
```bash
cat out2.txt | grep "Checking sstate" | awk '{print substr($0, length($0)-8, 9)}'
```
