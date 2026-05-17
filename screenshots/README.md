# Screenshots

Add these screenshots here after running the pipeline locally:

| File | What to capture |
|---|---|
| `pipeline-green.png` | Jenkins Stage View showing all stages green |
| `test-output.png` | Console output showing "7 passed, 0 failed" from Test stage |
| `artifacts.png` | Build artifacts panel showing the versioned .zip |

**How to take them:**
1. `docker compose up -d` in the repo root
2. Open http://localhost:8080
3. Run a build → wait for all stages to complete
4. Screenshot the Stage View (the coloured pipeline diagram)
5. Click into the Test stage → screenshot the console output
