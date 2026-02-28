# Project Principles

**Last Updated**: 2026-02-28
**Applies To**: All projects

---

## 🎯 Golden Rule

**Simple, Simple, Simple + Complete = Professional**

---

## 📐 Core Principles

### 1. Simplicity (3x)
- **Simple to use**: Zero configuration when possible
- **Simple to understand**: Clear, minimal documentation
- **Simple to maintain**: Few files, fewer dependencies

### 2. Completeness
- All necessary features present
- All edge cases handled
- All user questions answered

### 3. Professionalism
- Production-ready quality
- Follows best practices
- Easy for new users/contributors

---

## 🔴 Anti-Patterns

### Simple but Incomplete
- Missing error handling
- Undocumented edge cases
- Unclear requirements

### Complete but Complex
- Over-engineered solutions
- Too many options
- Excessive documentation

### Neither
- "TODO: implement"
- Missing both features and clarity
- Production issues

---

## ✅ The Sweet Spot

### Characteristics
- Concise code (few functions, clear purpose)
- Complete error handling
- Minimal but sufficient documentation
- Examples for key patterns

### Examples
- **Good docs**: 50 lines covering install, usage, FAQs
- **Good code**: One function with clear inputs/outputs/errors
- **Good APIs**: 3 required params, 2 optional max

---

## 📋 Decision Checklist

For every decision:

- [ ] **Simple?** Beginner can understand in 5 min
- [ ] **Complete?** Handles all necessary cases
- [ ] **Professional?** Production-ready quality

**If all ✅ → Proceed**
**If any ❌ → Refine**

---

## 🚀 Application to Different Domains

### Documentation
- **Simple**: Short, clear language
- **Complete**: Answers all user questions
- **Professional**: Grammar, structure, examples

### Code
- **Simple**: Small functions, clear names
- **Complete**: Error handling, validation
- **Professional**: Tests, comments, standards

### Architecture
- **Simple**: 2 layers > 3 layers
- **Complete**: All necessary components
- **Professional**: Clear separation, interfaces

### APIs
- **Simple**: Few parameters, clear types
- **Complete**: All error cases documented
- **Professional**: Versioning, deprecation policy

---

## 📊 Success Metrics

A project is successful when:

1. **New users** can start in 5 minutes
2. **Contributors** can understand structure in 30 minutes
3. **Maintenance** requires minimal documentation lookup
4. **Bugs** are rare and easy to fix

---

## 🎓 Origin

**Date**: 2026-02-28
**Project**: claude-code-for-android
**Context**: Documentation optimization

Lesson learned:
- Deleted 93% of docs (450KB → 68KB)
- Realized: "Simple but incomplete"
- Added back: Design, examples, optimization (+12KB)
- Result: Professional (80KB, complete)

**Formula**: Simple - Complete = Amateur
**Formula**: Simple + Complete = Professional

---

## ✨ Manifesto

We value:
- **Simplicity** over complexity
- **Clarity** over cleverness
- **Essential** over exhaustive
- **Professional** over amateur

**Simple, Simple, Simple + Complete = Professional**

This is our north star for all development.

---

**Scope**: All projects, all development, all decisions
**Status**: Active principle - use daily
