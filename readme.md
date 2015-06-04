#Fancom v1.0.4
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.0.4](http://img.shields.io/badge/pod-v1.0.4-yellow.svg)](http://www.fantomfactory.org/pods/afFancom)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

Fancom is a Fantom / COM Automation bridge for Fantom programs running on a JVM. It uses [JACOB](http://sourceforge.net/projects/jacob-project/) to make native calls to COM libraries via JNI. Fancom features:

- Runs on x86 and x64 environments supporting 32 bit and 64 bit JVMs.
- Supports COM Events
- COM encapsulation through surrogates
- Clean and simple API

## Install

Install `Fancom` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afFancom

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afFancom 1.0"]

## Documentation

Full API & fandocs are available on the [Fantom Pod Repository](http://pods.fantomfactory.org/pods/afFancom/).

## Install

To run, Fancom requires the JACOB file to be part of your Fantom installation. In particular:

- `afFancom.pod/lib/java/jacob-XXX.zip` needs to be copied to the `FAN_HOME/lib/java/ext/` folder and renamed to `.jar`
- `afFancom.pod/lib/dotnet/jacob-XXX.dll` needs to be copied to the `FAN_HOME/lib/dotnet/` folder

## Usage

Fancom is centred around the [Dispatch](http://pods.fantomfactory.org/pods/afFancom/api/Dispatch) and [Variant](http://pods.fantomfactory.org/pods/afFancom/api/Variant) classes.

[Dispatch](http://pods.fantomfactory.org/pods/afFancom/api/Dispatch) wraps a COM object (the IDispatch interface) and allows you to get / set properties and call methods on the component.

All parameters to and from Dispatch objects are encapsulated in [Variant](http://pods.fantomfactory.org/pods/afFancom/api/Variant) objects. A Variant holds a standard Fantom object ( `Int`, `Str`, `Bool` etc...) and converts it for usage by the COM object.

A simple example:

```
Dispatch outlook := Dispatch.makeFromProgId("Outlook.Application")
Str      version := outlook.getProperty(Variant("Version")).asStr
```

For ease of use, Fancom will convert all standard Fantom literals to Variants for you, so the last line could be written as:

```
version := outlook.getProperty("Version").asStr
```

(You can actually pass in *any* Fantom object as long as it looks like a [Variant Surrogate](http://pods.fantomfactory.org/pods/afFancom/api/Variant).)

Variants that reference other COM objects may be converted to `Dispatch` objects allowing chaining:

```
Dispatch objWord   := Dispatch.makeFromProgId("Word.Application")
Dispatch documents := objWord.getProperty("Documents").asDispatch
documents.call("Open", "myEssay.doc")
```

## Events

You can register any class to receive events from a COM object by calling:

    dispatch.registerForEvents(this)

Then when the COM object fires an event Fancom will look for a matching method on your event sink. The method is the name of the event, prefixed with `on`. For example, if the event is called `FalseRecognition` your handler method should be called `onFalseRecognition()`

