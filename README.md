# C-CMCP
Claude-Cursor Model Context Protocol
A validated AI-assisted development workflow that coordinates Claude.ai (design), Cursor AI (implementation), and API Claude (quality control) with human approval gates.
## What is C-CMCP?

C-CMCP is a portable workflow package that enables structured, quality-controlled development using multiple AI assistants working in coordination. Think of it as a development assembly line with built-in quality gates.

**The Four-Stage Pipeline:**

1. **Design** - Claude.ai creates detailed task specifications with must/should/could requirements
2. **Implementation** - Cursor AI reads tasks and implements the code changes
3. **Validation** - API Claude validates the work against original requirements
4. **Approval** - You review validation results and decide to accept or reject

## Key Features

- **Quality Gates** - Don't accept code changes until they pass validation
- **Structured Requirements** - Must/should/could priority system
- **Automated QC** - API Claude validates against acceptance criteria
- **Human Control** - You approve every step (task approval, final acceptance)
- **Portable** - Drop the C-CMCP folder into any project and go
- **Audit Trail** - Complete history of tasks, responses, and validations

## Quick Start

### Prerequisites
- Windows with PowerShell
- Anthropic API key (for validation)
- Cursor AI installed
- Claude.ai access

### Installation

1. **Copy C-CMCP folder into your project:**
   ```
   C:\Projects\YourProject\
   └── C-CMCP\
   ```

2. **Set your API key:**
   ```
   Environment Variables → User Variables → New
   Name: ANTHROPIC_API_KEY
   Value: sk-ant-api03-...
   ```

3. **Restart PowerShell** to load the environment variable

### First Run

1. **Start monitoring for tasks:**
   ```powershell
   cd C:\Projects\YourProject\C-CMCP
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
   .\monitor-claude-requests.ps1
   ```

2. **Get a task from Claude.ai:**
   - Ask Claude to create a task using the task-file-template.md
   - Download the task file to `claude-requests\`
   - Monitor script will prompt you to approve

3. **Process the approved task:**
   ```powershell
   .\process-approved-task.ps1
   ```

4. **Tell Cursor to implement:**
   - "Read the task in approved\task-*.md and implement it"
   - Cursor will create code and write a response file

5. **Validate the work:**
   ```powershell
   .\validate-cursor-work-v3.ps1
   ```

6. **Review and decide:**
   - Read the validation report
   - Test the implementation manually
   - Accept (keep changes) or reject (request fixes)

## Cost

Validation costs approximately $0.01-0.03 per task using Claude Sonnet 4.5 (varies by task complexity).

Example: 100 validated tasks ≈ $1-3 in API costs.

## Directory Structure

```
C-CMCP\
├── claude-requests\          # Tasks from Claude.ai (PENDING)
├── approved\                 # Tasks you've approved (APPROVED/PROCESSING)
├── cursor-responses\         # Implementation reports from Cursor
├── validation-reports\       # QC reports from API Claude
├── completed\                # Finished tasks (archived)
├── monitor-claude-requests.ps1    # Watch for new tasks
├── process-approved-task.ps1      # Prepare task for Cursor
├── validate-cursor-work-v3.ps1    # Run QC validation
├── task-file-template.md          # Template for creating tasks
├── cursor-response-template.md    # Template for Cursor responses
├── validation-report-template.md  # Template for validation reports
└── repo-rules-example.md          # Example project-specific rules
```

## When to Use C-CMCP

**Good for:**
- Feature development with clear requirements
- Code that needs validation against standards
- Projects where quality gates matter
- Learning/training on structured development
- Multiple developers needing consistency

**Not necessary for:**
- Quick experiments or prototypes
- Trivial changes (typo fixes, formatting)
- Tasks with vague or evolving requirements
- When you're the only developer and know the codebase cold

## Documentation

- [WORKFLOW.md](WORKFLOW.md) - Detailed process walkthrough
- [SETUP.md](SETUP.md) - Installation and configuration guide
- [TEMPLATES.md](TEMPLATES.md) - How to use the templates effectively
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions

## Philosophy

C-CMCP treats AI assistants as specialized team members:
- **Claude.ai** - Senior architect who designs solutions
- **Cursor AI** - Junior developer who implements code
- **API Claude** - QA engineer who validates quality
- **You** - Tech lead who approves and decides

The workflow enforces checkpoints that prevent low-quality work from reaching production while maintaining development velocity.

## Example Workflow

See [WORKFLOW.md](WORKFLOW.md) for a complete walkthrough with screenshots and examples.

## License

MIT - Use freely, modify as needed, no warranty provided.

## Credits

Created by Stan Pressman (PhantomKey Technologies)
Developed with assistance from Claude (Anthropic), Cursor AI

## Support

For issues, questions, or improvements:
- Review TROUBLESHOOTING.md first
- Check that your API key is valid and has credits
- Ensure templates are being followed correctly
- Verify PowerShell execution policy is set

---

**Version:** 1.0  
**Last Updated:** February 9, 2026  
**Status:** Production Ready
