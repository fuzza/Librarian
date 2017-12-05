# Librarian

Painless integration of Carthage frameworks

# Pre-conditions

1. Install [Carthage](https://github.com/Carthage/Carthage)

# Run sample

1. Install carthage dependencies by invoking `carhtage bootstrap --platform ios --no-use-binaries` in `Sample` folder
2. Open `Sample.xcworkspace` or `Sample.xcodeproj` in XCode
3. Go to root repository folder and execute `swift run Librarian`
4. Check sample project to see that following were done:
    * `Carthage/Build/iOS` folder is added to project's `FRAMEWORK_SEARCH_PATHS`
    * Frameworks are added to `Carthage` group in project root
    * Frameworks are added to `Link binary with libraries` for targets according to DSL congifuration
    * Copy-frameworks script phases are added to target's build phases according to DSL congifuration

# Editing sample

Integration DSL is a YAML file of the following structure:

```yaml
project: Sample/Sample.xcodeproj
targets:
  - name: Sample
    dependencies:
      - RxSwift
      - RxCocoa
  - name: SampleTests
    dependencies:
        - RxSwift
        - RxCocoa
        - RxBlocking
        - RxTest
```

DSL file for sample project can be found in `.librarian.yml` file inside repository.


# Upcoming plans

Since this is very early version of prototype there is a lot of missing functionality:

 - [ ] get rid of mess in the code
 - [ ] improve unit/integration test coverage
 - [ ] remove dependencies that were integrated previously but are missing in DSL
 - [ ] ability to de-integrate
 - [ ] add workspaces support
 - [ ] add support for integrating local frameworks within the same workspace
 - [ ] convert DSL to swift
 - [ ] support multiple platforms
 - [ ] add proper error handling and verbose messages

to be continued ...