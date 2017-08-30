/*
 * @(#)Checker.java                        2.1 2003/10/07
 *
 * Copyright (C) 1999, 2003 D.A. Watt and D.F. Brown
 * Dept. of Computing Science, University of Glasgow, Glasgow G12 8QQ Scotland
 * and School of Computer and Math Sciences, The Robert Gordon University,
 * St. Andrew Street, Aberdeen AB25 1HG, Scotland.
 * All rights reserved.
 *
 * This software is provided free for educational use only. It may
 * not be used for commercial purposes without the prior written permission
 * of the authors.
 */

package Triangle.ContextualAnalyzer;

import Triangle.AbstractSyntaxTrees.*;
import Triangle.ErrorReporter;
import Triangle.StdEnvironment;
import Triangle.SyntacticAnalyzer.SourcePosition;

/**
 * p. 136-168
 *
 * 1. Checks whether the source program, represented by its AST, satisfies the
 *    language's scope rules and type rules.
 *
 * 2. Also decorates the AST as follows:
 *   (a) Each applied occurrence of an identifier or operator is linked to
 *       the corresponding declaration of that identifier or operator.
 *   (b) Each expression and value-or-variable-name is decorated by its type.
 *   (c) Each type identifier is replaced by the type it denotes.
 *
 * 3. Standard types are represented by small ASTs.
 *
 * 4. Reports that the identifier or operator used at a leaf of the AST has not been declared.
 */
public final class Checker implements Visitor {

    // Always returns null. Does not use the given object.
    private static final SourcePosition dummyPos = new SourcePosition();

    private static final Identifier dummyI = new Identifier("", dummyPos);

    private final IdentificationTable indTable;
    private final ErrorReporter reporter;

    public Checker(ErrorReporter reporter) {
        this.reporter = reporter;
        this.indTable = new IdentificationTable();

        establishStdEnvironment();
    }

    private static TypeDenoter checkFieldIdentifier(FieldTypeDenoter fieldTypeDenoter, Identifier I) {

        if (fieldTypeDenoter instanceof MultipleFieldTypeDenoter) {

            MultipleFieldTypeDenoter ft = (MultipleFieldTypeDenoter) fieldTypeDenoter;

            if (ft.I.spelling.compareTo(I.spelling) == 0) {
                I.decl = fieldTypeDenoter;
                return ft.T;

            } else {
                return checkFieldIdentifier(ft.FT, I);
            }

        } else if (fieldTypeDenoter instanceof SingleFieldTypeDenoter) {

            SingleFieldTypeDenoter ft = (SingleFieldTypeDenoter) fieldTypeDenoter;

            if (ft.I.spelling.compareTo(I.spelling) == 0) {
                I.decl = fieldTypeDenoter;
                return ft.T;
            }
        }

        return StdEnvironment.errorType;
    }

//_____________________________________________________________________________
//                                                                    COMMANDS

    // 1. Check that the given command is well formed
    // 2. Always returns null and does not use the given subtree(phrase)

    public Object visitAssignCommand(AssignCommand assignCommand, Object _) {

        TypeDenoter vType = (TypeDenoter) assignCommand.V.visit(this, null);
        TypeDenoter eType = (TypeDenoter) assignCommand.E.visit(this, null);

        // only variables could be assigned
        if (!assignCommand.V.variable) {
            reporter.reportError("LHS of assignment is not a variable", "", assignCommand.V.position);
        }

        if (!eType.equals(vType)) {
            reporter.reportError("assignment incompatibility", "", assignCommand.position);
        }

        return null;
    }

    public Object visitCallCommand(CallCommand callCommand, Object _) {

        Declaration binding = (Declaration) callCommand.I.visit(this, null);

        if (binding == null) {
            reportUndeclared(callCommand.I);

        } else if (binding instanceof ProcDeclaration) {
            callCommand.APS.visit(this, ((ProcDeclaration) binding).FPS);

        } else if (binding instanceof ProcFormalParameter) {
            callCommand.APS.visit(this, ((ProcFormalParameter) binding).FPS);

        } else {
            reporter.reportError("\"%\" is not a procedure identifier",
                    callCommand.I.spelling, callCommand.I.position);
        }

        return null;
    }

    public Object visitEmptyCommand(EmptyCommand __, Object _) {
        return null;
    }

    public Object visitIfCommand(IfCommand ifCommand, Object _) {

        TypeDenoter eType = (TypeDenoter) ifCommand.E.visit(this, null);

        // 'if' expression should be boolean type
        if (!eType.equals(StdEnvironment.booleanType)) {
            reporter.reportError("Boolean expression expected here", "", ifCommand.E.position);
        }

        ifCommand.C1.visit(this, null);
        ifCommand.C2.visit(this, null);

        return null;
    }

    public Object visitLetCommand(LetCommand letCommand, Object _) {
        indTable.openScope();

        letCommand.D.visit(this, null);
        letCommand.C.visit(this, null);

        indTable.closeScope();

        return null;
    }

    public Object visitSequentialCommand(SequentialCommand sequentialCommand, Object _) {
        sequentialCommand.C1.visit(this, null);
        sequentialCommand.C2.visit(this, null);

        return null;
    }

    public Object visitWhileCommand(WhileCommand whileCommand, Object _) {

        TypeDenoter eType = (TypeDenoter) whileCommand.E.visit(this, null);

        // 'while' expression should be boolean type
        if (!eType.equals(StdEnvironment.booleanType)) {
            reporter.reportError("Boolean expression expected here", "", whileCommand.E.position);
        }

        whileCommand.C.visit(this, null);

        return null;
    }

//_____________________________________________________________________________
//                                                                 EXPRESSIONS

    // 1. Checks that the expression is well formed
    // 2. Decorates the expression node with its inferred type
    // 3. Return that type

    public Object visitArrayExpression(ArrayExpression arrayExpression, Object _) {

        TypeDenoter elemType = (TypeDenoter) arrayExpression.AA.visit(this, null);

        IntegerLiteral il = new IntegerLiteral(Integer.toString(arrayExpression.AA.elemCount), arrayExpression.position);

        // V[E] could not be found(dynamic) in the AST so we particular one
        arrayExpression.type = new ArrayTypeDenoter(il, elemType, arrayExpression.position);

        return arrayExpression.type;
    }

    public Object visitBinaryExpression(BinaryExpression binaryExpression, Object _) {

        TypeDenoter e1Type = (TypeDenoter) binaryExpression.E1.visit(this, null);
        TypeDenoter e2Type = (TypeDenoter) binaryExpression.E2.visit(this, null);

        // return pointer to the 'declaration' of Op so
        Declaration binding = (Declaration) binaryExpression.Op.visit(this, null);

        if (binding == null) {
            reportUndeclared(binaryExpression.Op);

        } else {

            if (!(binding instanceof BinaryOperatorDeclaration)) {
                reporter.reportError("\"%\" is not a binary operator", binaryExpression.Op.spelling, binaryExpression.Op.position);
            }

            BinaryOperatorDeclaration bbinding = (BinaryOperatorDeclaration) binding;

            if (bbinding.ARG1 == StdEnvironment.anyType) {

                // this operator must be "=" or "\="
                if (!e1Type.equals(e2Type)) {
                    reporter.reportError("incompatible argument types for \"%\"", binaryExpression.Op.spelling, binaryExpression.position);
                }

            } else if (!e1Type.equals(bbinding.ARG1)) {
                reporter.reportError("wrong argument type for \"%\"", binaryExpression.Op.spelling, binaryExpression.E1.position);

            } else if (!e2Type.equals(bbinding.ARG2)) {
                reporter.reportError("wrong argument type for \"%\"", binaryExpression.Op.spelling, binaryExpression.E2.position);
            }

            binaryExpression.type = bbinding.RES;
        }

        return binaryExpression.type;
    }

    public Object visitCallExpression(CallExpression callExpression, Object _) {

        Declaration binding = (Declaration) callExpression.I.visit(this, null);

        // NOTE that the subtree is passed when visit ActualParameterSequence (APS)

        if (binding == null) {
            reportUndeclared(callExpression.I);
            callExpression.type = StdEnvironment.errorType;

        } else if (binding instanceof FuncDeclaration) {
            callExpression.APS.visit(this, ((FuncDeclaration) binding).FPS);
            callExpression.type = ((FuncDeclaration) binding).T;

        } else if (binding instanceof FuncFormalParameter) {
            callExpression.APS.visit(this, ((FuncFormalParameter) binding).FPS);
            callExpression.type = ((FuncFormalParameter) binding).T;

        } else {
            reporter.reportError("\"%\" is not a function identifier", callExpression.I.spelling, callExpression.I.position);
        }

        return callExpression.type;
    }

    public Object visitCharacterExpression(CharacterExpression charExpression, Object _) {
        charExpression.type = StdEnvironment.charType;

        return charExpression.type;
    }

    public Object visitEmptyExpression(EmptyExpression emptyExpression, Object _) {
        return null;
    }

    public Object visitIfExpression(IfExpression ifExpression, Object _) {

        TypeDenoter e1Type = (TypeDenoter) ifExpression.E1.visit(this, null);

        if (!e1Type.equals(StdEnvironment.booleanType)) {
            reporter.reportError("Boolean expression expected here", "", ifExpression.E1.position);
        }

        TypeDenoter e2Type = (TypeDenoter) ifExpression.E2.visit(this, null);
        TypeDenoter e3Type = (TypeDenoter) ifExpression.E3.visit(this, null);

        if (!e2Type.equals(e3Type)) {
            reporter.reportError("incompatible limbs in if-expression", "", ifExpression.position);
        }

        // e2Type is equal to e3Type so take one of them
        ifExpression.type = e2Type;

        return ifExpression.type;
    }

    public Object visitIntegerExpression(IntegerExpression intExpression, Object _) {
        intExpression.type = StdEnvironment.integerType;

        return intExpression.type;
    }

    public Object visitLetExpression(LetExpression letExpression, Object _) {
        indTable.openScope();

        letExpression.D.visit(this, null);
        letExpression.type = (TypeDenoter) letExpression.E.visit(this, null);

        indTable.closeScope();

        return letExpression.type;
    }

    public Object visitRecordExpression(RecordExpression recordExpression, Object _) {

        FieldTypeDenoter rType = (FieldTypeDenoter) recordExpression.RA.visit(this, null);
        recordExpression.type = new RecordTypeDenoter(rType, recordExpression.position);

        return recordExpression.type;
    }

    public Object visitUnaryExpression(UnaryExpression unaryExpression, Object _) {

        TypeDenoter eType = (TypeDenoter) unaryExpression.E.visit(this, null);

        Declaration binding = (Declaration) unaryExpression.Op.visit(this, null);

        if (binding == null) {
            reportUndeclared(unaryExpression.Op);
            unaryExpression.type = StdEnvironment.errorType;

        } else if (!(binding instanceof UnaryOperatorDeclaration)) {
            reporter.reportError("\"%\" is not a unary operator", unaryExpression.Op.spelling, unaryExpression.Op.position);

        } else {
            UnaryOperatorDeclaration ubinding = (UnaryOperatorDeclaration) binding;

            if (!eType.equals(ubinding.ARG)) {
                reporter.reportError("wrong argument type for \"%\"", unaryExpression.Op.spelling, unaryExpression.Op.position);
            }

            unaryExpression.type = ubinding.RES;
        }
        return unaryExpression.type;
    }

    public Object visitVnameExpression(VnameExpression vnameExpression, Object o) {

        // Vname successors return inferred types
        vnameExpression.type = (TypeDenoter) vnameExpression.V.visit(this, null);

        return vnameExpression.type;
    }

//_____________________________________________________________________________
//                                                                DECLARATIONS

    // 1. Always returns null and does not use the given subtree(phrase)
    // 2. Enters all declared identifiers into the identification table

    public Object visitBinaryOperatorDeclaration(BinaryOperatorDeclaration binaryOpDeclaration, Object _) {
        return null;
    }

    public Object visitConstDeclaration(ConstDeclaration constDeclaration, Object _) {

        // Just verify the type of the expression, but more important is the identifier.
        // It it is defined more than ones even with the same type is again a error.

        constDeclaration.E.visit(this, null);

        indTable.enter(constDeclaration.I.spelling, constDeclaration);

        if (constDeclaration.duplicated) {
            reporter.reportError("identifier \"%\" already declared", constDeclaration.I.spelling, constDeclaration.position);
        }

        return null;
    }

    public Object visitFuncDeclaration(FuncDeclaration funcDeclaration, Object _) {

        // eliminate type identifiers
        funcDeclaration.T = (TypeDenoter) funcDeclaration.T.visit(this, null);

        indTable.enter(funcDeclaration.I.spelling, funcDeclaration);

        if (funcDeclaration.duplicated) {
            reporter.reportError("identifier \"%\" already declared", funcDeclaration.I.spelling, funcDeclaration.position);
        }

        indTable.openScope();

        funcDeclaration.FPS.visit(this, null);
        TypeDenoter eType = (TypeDenoter) funcDeclaration.E.visit(this, null);

        indTable.closeScope();

        if (!funcDeclaration.T.equals(eType)) {
            reporter.reportError("body of function \"%\" has wrong type", funcDeclaration.I.spelling, funcDeclaration.E.position);
        }

        return null;
    }

    public Object visitProcDeclaration(ProcDeclaration procDeclaration, Object _) {

        indTable.enter(procDeclaration.I.spelling, procDeclaration);

        if (procDeclaration.duplicated) {
            reporter.reportError("identifier \"%\" already declared", procDeclaration.I.spelling, procDeclaration.position);
        }

        indTable.openScope();

        procDeclaration.FPS.visit(this, null);
        procDeclaration.C.visit(this, null);

        indTable.closeScope();

        return null;
    }

    public Object visitSequentialDeclaration(SequentialDeclaration sequentialDeclaration, Object _) {

        sequentialDeclaration.D1.visit(this, null);
        sequentialDeclaration.D2.visit(this, null);

        return null;
    }

    public Object visitTypeDeclaration(TypeDeclaration typeDeclaration, Object _) {

        typeDeclaration.T = (TypeDenoter) typeDeclaration.T.visit(this, null);

        indTable.enter(typeDeclaration.I.spelling, typeDeclaration);

        if (typeDeclaration.duplicated) {
            reporter.reportError("identifier \"%\" already declared", typeDeclaration.I.spelling, typeDeclaration.position);
        }

        return null;
    }

    // Always returns null
    public Object visitUnaryOperatorDeclaration(UnaryOperatorDeclaration ast, Object _) {
        return null;
    }

    public Object visitVarDeclaration(VarDeclaration varDeclaration, Object _) {

        // eliminate type identifiers
        varDeclaration.T = (TypeDenoter) varDeclaration.T.visit(this, null);

        indTable.enter(varDeclaration.I.spelling, varDeclaration);

        if (varDeclaration.duplicated) {
            reporter.reportError("identifier \"%\" already declared", varDeclaration.I.spelling, varDeclaration.position);
        }

        return null;
    }

//_____________________________________________________________________________
//                                                            ARRAY AGGREGATES

    // 1. Decorate 'elemCount'
    // 2. Return type

    public Object visitMultipleArrayAggregate(MultipleArrayAggregate multiArrayAggregate, Object _) {

        TypeDenoter eType = (TypeDenoter) multiArrayAggregate.E.visit(this, null);
        TypeDenoter elemType = (TypeDenoter) multiArrayAggregate.AA.visit(this, null);

        // how many elements will be yield p.391
        multiArrayAggregate.elemCount = multiArrayAggregate.AA.elemCount + 1;

        if (!eType.equals(elemType)) {
            reporter.reportError("incompatible array-aggregate element", "", multiArrayAggregate.E.position);
        }

        return elemType;
    }

    public Object visitSingleArrayAggregate(SingleArrayAggregate singleArrayAggregate, Object _) {

        TypeDenoter elemType = (TypeDenoter) singleArrayAggregate.E.visit(this, null);

        // e.g [5] select 5th element
        singleArrayAggregate.elemCount = 1;

        return elemType;
    }

    public Object visitMultipleRecordAggregate(MultipleRecordAggregate multiRecordAggregate, Object _) {

        TypeDenoter eType = (TypeDenoter) multiRecordAggregate.E.visit(this, null);
        FieldTypeDenoter rType = (FieldTypeDenoter) multiRecordAggregate.RA.visit(this, null);

        // !!!
        TypeDenoter fType = checkFieldIdentifier(rType, multiRecordAggregate.I);

        if (fType != StdEnvironment.errorType) {
            reporter.reportError("duplicate field \"%\" in record", multiRecordAggregate.I.spelling, multiRecordAggregate.I.position);
        }

        // number of elements could vary that's why we create a particular one
        multiRecordAggregate.type = new MultipleFieldTypeDenoter(multiRecordAggregate.I, eType, rType, multiRecordAggregate.position);

        return multiRecordAggregate.type;
    }

    public Object visitSingleRecordAggregate(SingleRecordAggregate singleRecordAggregate, Object _) {

        TypeDenoter eType = (TypeDenoter) singleRecordAggregate.E.visit(this, null);
        singleRecordAggregate.type = new SingleFieldTypeDenoter(singleRecordAggregate.I, eType, singleRecordAggregate.position);

        return singleRecordAggregate.type;
    }

//_____________________________________________________________________________
//                                                           FORMAL PARAMETERS

    // Most of them:
    //
    // 1. Open scope
    // 2. Enter parameters in identification table

    public Object visitConstFormalParameter(ConstFormalParameter constFormalParam, Object _) {

        constFormalParam.T = (TypeDenoter) constFormalParam.T.visit(this, null);
        indTable.enter(constFormalParam.I.spelling, constFormalParam);

        if (constFormalParam.duplicated) {
            reporter.reportError("duplicated formal parameter \"%\"", constFormalParam.I.spelling, constFormalParam.position);
        }

        return null;
    }

    public Object visitFuncFormalParameter(FuncFormalParameter funcFormalParam, Object _) {

        indTable.openScope();

        funcFormalParam.FPS.visit(this, null);

        indTable.closeScope();

        funcFormalParam.T = (TypeDenoter) funcFormalParam.T.visit(this, null);

        indTable.enter(funcFormalParam.I.spelling, funcFormalParam);

        if (funcFormalParam.duplicated) {
            reporter.reportError("duplicated formal parameter \"%\"", funcFormalParam.I.spelling, funcFormalParam.position);
        }

        return null;
    }

    public Object visitProcFormalParameter(ProcFormalParameter procFormalParam, Object _) {

        indTable.openScope();

        procFormalParam.FPS.visit(this, null);

        indTable.closeScope();

        indTable.enter(procFormalParam.I.spelling, procFormalParam);

        if (procFormalParam.duplicated) {
            reporter.reportError("duplicated formal parameter \"%\"", procFormalParam.I.spelling, procFormalParam.position);
        }

        return null;
    }

    public Object visitVarFormalParameter(VarFormalParameter varFormalParam, Object _) {

        varFormalParam.T = (TypeDenoter) varFormalParam.T.visit(this, null);

        indTable.enter(varFormalParam.I.spelling, varFormalParam);

        if (varFormalParam.duplicated) {
            reporter.reportError("duplicated formal parameter \"%\"", varFormalParam.I.spelling, varFormalParam.position);
        }

        return null;
    }

    public Object visitEmptyFormalParameterSequence(EmptyFormalParameterSequence __, Object _) {
        return null;
    }

    public Object visitMultipleFormalParameterSequence(MultipleFormalParameterSequence multiFormalParamSeq, Object _) {
        multiFormalParamSeq.FP.visit(this, null);
        multiFormalParamSeq.FPS.visit(this, null);

        return null;
    }

    public Object visitSingleFormalParameterSequence(SingleFormalParameterSequence singleFormalParamSeq, Object _) {
        singleFormalParamSeq.FP.visit(this, null);

        return null;
    }

//_____________________________________________________________________________
//                                                           ACTUAL PARAMETERS


    public Object visitConstActualParameter(ConstActualParameter constActualParam, Object formalParameter) {

        // use passed FormalParameter
        FormalParameter fp = (FormalParameter) formalParameter;

        TypeDenoter eType = (TypeDenoter) constActualParam.E.visit(this, null);

        if (!(fp instanceof ConstFormalParameter)) {
            reporter.reportError("const actual parameter not expected here", "", constActualParam.position);

        } else if (!eType.equals(((ConstFormalParameter) fp).T)) {
            reporter.reportError("wrong type for const actual parameter", "", constActualParam.E.position);
        }

        return null;
    }

    public Object visitFuncActualParameter(FuncActualParameter funcActualParam, Object formalParameter) {

        FormalParameter fp = (FormalParameter) formalParameter;

        Declaration binding = (Declaration) funcActualParam.I.visit(this, null);

        if (binding == null) {
            reportUndeclared(funcActualParam.I);

        } else if (!(binding instanceof FuncDeclaration || binding instanceof FuncFormalParameter)) {
            reporter.reportError("\"%\" is not a function identifier", funcActualParam.I.spelling, funcActualParam.I.position);

        } else if (!(fp instanceof FuncFormalParameter)) {
            reporter.reportError("func actual parameter not expected here", "", funcActualParam.position);

        } else {

            FormalParameterSequence FPS;
            TypeDenoter T;

            if (binding instanceof FuncDeclaration) {
                FPS = ((FuncDeclaration) binding).FPS;
                T = ((FuncDeclaration) binding).T;

            } else {
                FPS = ((FuncFormalParameter) binding).FPS;
                T = ((FuncFormalParameter) binding).T;
            }

            if (!FPS.equals(((FuncFormalParameter) fp).FPS)) {
                reporter.reportError("wrong signature for function \"%\"", funcActualParam.I.spelling, funcActualParam.I.position);

            } else if (!T.equals(((FuncFormalParameter) fp).T)) {
                reporter.reportError("wrong type for function \"%\"", funcActualParam.I.spelling, funcActualParam.I.position);

            }
        }

        return null;
    }

    public Object visitProcActualParameter(ProcActualParameter procActualParam, Object formalParameter) {

        // use passed FormalParameter
        FormalParameter fp = (FormalParameter) formalParameter;

        Declaration binding = (Declaration) procActualParam.I.visit(this, null);

        if (binding == null) {
            reportUndeclared(procActualParam.I);

        } else if (!(binding instanceof ProcDeclaration || binding instanceof ProcFormalParameter)) {
            reporter.reportError("\"%\" is not a procedure identifier", procActualParam.I.spelling, procActualParam.I.position);

        } else if (!(fp instanceof ProcFormalParameter)) {
            reporter.reportError("proc actual parameter not expected here", "", procActualParam.position);

        } else {

            FormalParameterSequence FPS;

            if (binding instanceof ProcDeclaration) {
                FPS = ((ProcDeclaration) binding).FPS;

            } else {
                FPS = ((ProcFormalParameter) binding).FPS;
            }

            if (!FPS.equals(((ProcFormalParameter) fp).FPS)) {
                reporter.reportError("wrong signature for procedure \"%\"", procActualParam.I.spelling, procActualParam.I.position);
            }
        }

        return null;
    }

    public Object visitVarActualParameter(VarActualParameter varActualParam, Object formalParameter) {

        // Use passed FormalParameter
        FormalParameter fp = (FormalParameter) formalParameter;

        TypeDenoter vType = (TypeDenoter) varActualParam.V.visit(this, null);

        if (!varActualParam.V.variable) {
            reporter.reportError("actual parameter is not a variable", "", varActualParam.V.position);

        } else if (!(fp instanceof VarFormalParameter)) {
            reporter.reportError("var actual parameter not expected here", "", varActualParam.V.position);

        } else if (!vType.equals(((VarFormalParameter) fp).T)) {
            reporter.reportError("wrong type for var actual parameter", "", varActualParam.V.position);
        }

        return null;
    }

    public Object visitEmptyActualParameterSequence(EmptyActualParameterSequence emptyActualParamSeq, Object formalParameterSeq) {

        // use passed FormalParameterSequence
        FormalParameterSequence fps = (FormalParameterSequence) formalParameterSeq;

        if (!(fps instanceof EmptyFormalParameterSequence)) {
            reporter.reportError("too few actual parameters", "", emptyActualParamSeq.position);
        }

        return null;
    }

    public Object visitMultipleActualParameterSequence(MultipleActualParameterSequence multiActualParamSeq, Object formalParameterSeq) {

        // use passed FormalParameterSequence
        FormalParameterSequence fps = (FormalParameterSequence) formalParameterSeq;

        if (!(fps instanceof MultipleFormalParameterSequence)) {
            reporter.reportError("too many actual parameters", "", multiActualParamSeq.position);

        } else {
            multiActualParamSeq.AP.visit(this, ((MultipleFormalParameterSequence) fps).FP);
            multiActualParamSeq.APS.visit(this, ((MultipleFormalParameterSequence) fps).FPS);
        }

        return null;
    }

    public Object visitSingleActualParameterSequence(SingleActualParameterSequence singleActualParamSeq, Object formalParameterSeq) {

        // use passed FormalParameterSequence
        FormalParameterSequence fps = (FormalParameterSequence) formalParameterSeq;

        if (!(fps instanceof SingleFormalParameterSequence)) {
            reporter.reportError("incorrect number of actual parameters", "", singleActualParamSeq.position);

        } else {
            singleActualParamSeq.AP.visit(this, ((SingleFormalParameterSequence) fps).FP);
        }

        return null;
    }

//_____________________________________________________________________________
//                                                               TYPE DENOTERS

    // Return denoters (sub-tree)

    public Object visitAnyTypeDenoter(AnyTypeDenoter __, Object _) {
        return StdEnvironment.anyType;
    }

    public Object visitArrayTypeDenoter(ArrayTypeDenoter arrayTypeDenoter, Object _) {

        arrayTypeDenoter.T = (TypeDenoter) arrayTypeDenoter.T.visit(this, null);

        if (Integer.valueOf(arrayTypeDenoter.IL.spelling) == 0) {
            reporter.reportError("arrays must not be empty", "", arrayTypeDenoter.IL.position);
        }

        return arrayTypeDenoter;
    }

    public Object visitBoolTypeDenoter(BoolTypeDenoter __, Object _) {
        return StdEnvironment.booleanType;
    }

    public Object visitCharTypeDenoter(CharTypeDenoter __, Object _) {
        return StdEnvironment.charType;
    }

    public Object visitErrorTypeDenoter(ErrorTypeDenoter __, Object _) {
        return StdEnvironment.errorType;
    }

    // e.g. var currentline: Line
    // So we have to find using Line the actual type declaration
    public Object visitSimpleTypeDenoter(SimpleTypeDenoter simpleTypeDenoter, Object _) {

        Declaration binding = (Declaration) simpleTypeDenoter.I.visit(this, null);

        if (binding == null) {
            reportUndeclared(simpleTypeDenoter.I);

            return StdEnvironment.errorType;

        } else if (!(binding instanceof TypeDeclaration)) {
            reporter.reportError("\"%\" is not a type identifier", simpleTypeDenoter.I.spelling, simpleTypeDenoter.I.position);

            return StdEnvironment.errorType;
        }

        return ((TypeDeclaration) binding).T;
    }

    public Object visitIntTypeDenoter(IntTypeDenoter __, Object _) {
        return StdEnvironment.integerType;
    }

    public Object visitRecordTypeDenoter(RecordTypeDenoter recordTypeDenoter, Object _) {
        recordTypeDenoter.FT = (FieldTypeDenoter) recordTypeDenoter.FT.visit(this, null);

        return recordTypeDenoter;
    }

    // Return the location in AST where MultipleFieldTypeDenoter is declared
    public Object visitMultipleFieldTypeDenoter(MultipleFieldTypeDenoter multiFieldTypeDenoter, Object _) {

        multiFieldTypeDenoter.T = (TypeDenoter) multiFieldTypeDenoter.T.visit(this, null);
        multiFieldTypeDenoter.FT.visit(this, null);

        return multiFieldTypeDenoter;
    }

    public Object visitSingleFieldTypeDenoter(SingleFieldTypeDenoter singleFieldTypeDenoter, Object _) {
        singleFieldTypeDenoter.T = (TypeDenoter) singleFieldTypeDenoter.T.visit(this, null);
        return singleFieldTypeDenoter;
    }

//_____________________________________________________________________________
//                                         Literals, Identifiers and Operators

    // Return bindings

    public Object visitCharacterLiteral(CharacterLiteral __, Object _) {
        return StdEnvironment.charType;
    }

    /**
     * Links an applied occurrence of an identifier to the corresponding declaration (if any).
     * Its result is a pointer to that declaration.
     */
    public Object visitIdentifier(Identifier identifier, Object _) {
        Declaration binding = indTable.retrieve(identifier.spelling);

        if (binding != null) {
            identifier.decl = binding;
        }

        return binding;
    }

    public Object visitIntegerLiteral(IntegerLiteral __, Object _) {
        return StdEnvironment.integerType;
    }

    public Object visitOperator(Operator O, Object _) {
        // Binary or Unary Operators could be declared above
        Declaration binding = indTable.retrieve(O.spelling);

        if (binding != null) {
            O.decl = binding;
        }

        return binding;
    }

//_____________________________________________________________________________
//                                                      VALUE or VARIABLE NAMES

    // 1. Checks that the value-or-variable-name is well-formed
    // 2. Decorates it with its inferred type
    // 3. Add indication of whether it is a variable or not
    // 4. The method's result is the inferred type

    public Object visitDotVname(DotVname dotVname, Object _) {
        dotVname.type = null;

        TypeDenoter vType = (TypeDenoter) dotVname.V.visit(this, null);

        dotVname.variable = dotVname.V.variable;

        if (!(vType instanceof RecordTypeDenoter)) {
            reporter.reportError("record expected here", "", dotVname.V.position);

        } else {
            dotVname.type = checkFieldIdentifier(((RecordTypeDenoter) vType).FT, dotVname.I);

            if (dotVname.type == StdEnvironment.errorType) {
                reporter.reportError("no field \"%\" in this record type", dotVname.I.spelling, dotVname.I.position);
            }
        }

        return dotVname.type;
    }

    public Object visitSimpleVname(SimpleVname simpleVname, Object _) {

        simpleVname.variable = false;
        simpleVname.type = StdEnvironment.errorType;

        Declaration binding = (Declaration) simpleVname.I.visit(this, null);

        if (binding == null) {
            reportUndeclared(simpleVname.I);

        } else if (binding instanceof ConstDeclaration) {
            simpleVname.type = ((ConstDeclaration) binding).E.type;
            simpleVname.variable = false;

        } else if (binding instanceof VarDeclaration) {
            simpleVname.type = ((VarDeclaration) binding).T;
            simpleVname.variable = true;

        } else if (binding instanceof ConstFormalParameter) {
            simpleVname.type = ((ConstFormalParameter) binding).T;
            simpleVname.variable = false;

        } else if (binding instanceof VarFormalParameter) {
            simpleVname.type = ((VarFormalParameter) binding).T;
            simpleVname.variable = true;

        } else {
            reporter.reportError("\"%\" is not a const or var identifier", simpleVname.I.spelling, simpleVname.I.position);
        }

        return simpleVname.type;
    }

    public Object visitSubscriptVname(SubscriptVname subscriptVname, Object _) {

        TypeDenoter vType = (TypeDenoter) subscriptVname.V.visit(this, null);
        subscriptVname.variable = subscriptVname.V.variable;

        TypeDenoter eType = (TypeDenoter) subscriptVname.E.visit(this, null);

        if (vType != StdEnvironment.errorType) {

            if (!(vType instanceof ArrayTypeDenoter)) {
                reporter.reportError("array expected here", "", subscriptVname.V.position);

            } else {

                if (!eType.equals(StdEnvironment.integerType)) {
                    reporter.reportError("Integer expression expected here", "", subscriptVname.E.position);
                }

                subscriptVname.type = ((ArrayTypeDenoter) vType).T;
            }
        }

        return subscriptVname.type;
    }

//_____________________________________________________________________________
//                                                                    PROGRAMS

    public Object visitProgram(Program program, Object _) {
        program.C.visit(this, null);

        return null;
    }

    // Checker entry point
    public void check(Program program) {
        program.visit(this, null);
    }

    private void reportUndeclared(Terminal leaf) {
        reporter.reportError("\"%\" is not declared", leaf.spelling, leaf.position);
    }

//_____________________________________________________________________________
//                                                             STD ENVIRONMENT

    // Creates 'small' ASTs to represent the standard types.
    //
    // Creates small ASTs to represent "declarations" of standard types, constants, procedures, functions, and operators.
    // Enters these "declarations" in the identification table.
    //
    // This "declaration" summarises the operator's type info.

    private TypeDeclaration declareStdType(String name, TypeDenoter typedenoter) {

        TypeDeclaration binding;

        binding = new TypeDeclaration(new Identifier(name, dummyPos), typedenoter, dummyPos);
        indTable.enter(name, binding);

        return binding;
    }

    private ConstDeclaration declareStdConst(String name, TypeDenoter constType) {

        IntegerExpression constExpr;
        ConstDeclaration binding;

        // constExpr used only as a placeholder for constType
        constExpr = new IntegerExpression(null, dummyPos);
        constExpr.type = constType;

        binding = new ConstDeclaration(new Identifier(name, dummyPos), constExpr, dummyPos);

        indTable.enter(name, binding);

        return binding;
    }

    private ProcDeclaration declareStdProc(String name, FormalParameterSequence fps) {

        ProcDeclaration binding;

        binding = new ProcDeclaration(new Identifier(name, dummyPos), fps, new EmptyCommand(dummyPos), dummyPos);

        indTable.enter(name, binding);
        return binding;
    }


    private FuncDeclaration declareStdFunc(String name, FormalParameterSequence fps, TypeDenoter resultType) {

        FuncDeclaration binding;

        binding = new FuncDeclaration(new Identifier(name, dummyPos), fps, resultType, new EmptyExpression(dummyPos), dummyPos);
        indTable.enter(name, binding);

        return binding;
    }

    private UnaryOperatorDeclaration declareStdUnaryOp(String op, TypeDenoter argType, TypeDenoter resultType) {

        UnaryOperatorDeclaration binding;

        binding = new UnaryOperatorDeclaration(new Operator(op, dummyPos), argType, resultType, dummyPos);
        indTable.enter(op, binding);

        return binding;
    }

    private BinaryOperatorDeclaration declareStdBinaryOp(String op, TypeDenoter arg1Type, TypeDenoter arg2type,
                                                         TypeDenoter resultType) {

        BinaryOperatorDeclaration binding;

        binding = new BinaryOperatorDeclaration(new Operator(op, dummyPos), arg1Type, arg2type, resultType, dummyPos);
        indTable.enter(op, binding);

        return binding;
    }

    private void establishStdEnvironment() {

        // idTable.startIdentification();
        StdEnvironment.booleanType = new BoolTypeDenoter(dummyPos);
        StdEnvironment.integerType = new IntTypeDenoter(dummyPos);
        StdEnvironment.charType = new CharTypeDenoter(dummyPos);
        StdEnvironment.anyType = new AnyTypeDenoter(dummyPos);
        StdEnvironment.errorType = new ErrorTypeDenoter(dummyPos);

        StdEnvironment.booleanDecl = declareStdType("Boolean", StdEnvironment.booleanType);
        StdEnvironment.falseDecl = declareStdConst("false", StdEnvironment.booleanType);
        StdEnvironment.trueDecl = declareStdConst("true", StdEnvironment.booleanType);
        StdEnvironment.notDecl = declareStdUnaryOp("\\", StdEnvironment.booleanType, StdEnvironment.booleanType);
        StdEnvironment.andDecl = declareStdBinaryOp("/\\", StdEnvironment.booleanType, StdEnvironment.booleanType, StdEnvironment.booleanType);
        StdEnvironment.orDecl = declareStdBinaryOp("\\/", StdEnvironment.booleanType, StdEnvironment.booleanType, StdEnvironment.booleanType);

        StdEnvironment.integerDecl = declareStdType("Integer", StdEnvironment.integerType);
        StdEnvironment.maxintDecl = declareStdConst("maxint", StdEnvironment.integerType);
        StdEnvironment.addDecl = declareStdBinaryOp("+", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.integerType);
        StdEnvironment.subtractDecl = declareStdBinaryOp("-", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.integerType);
        StdEnvironment.multiplyDecl = declareStdBinaryOp("*", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.integerType);
        StdEnvironment.divideDecl = declareStdBinaryOp("/", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.integerType);
        StdEnvironment.moduloDecl = declareStdBinaryOp("//", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.integerType);
        StdEnvironment.lessDecl = declareStdBinaryOp("<", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.booleanType);
        StdEnvironment.notgreaterDecl = declareStdBinaryOp("<=", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.booleanType);
        StdEnvironment.greaterDecl = declareStdBinaryOp(">", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.booleanType);
        StdEnvironment.notlessDecl = declareStdBinaryOp(">=", StdEnvironment.integerType, StdEnvironment.integerType, StdEnvironment.booleanType);

        StdEnvironment.charDecl = declareStdType("Char", StdEnvironment.charType);
        StdEnvironment.chrDecl = declareStdFunc("chr", new SingleFormalParameterSequence(new ConstFormalParameter(dummyI, StdEnvironment.integerType, dummyPos), dummyPos), StdEnvironment.charType);
        StdEnvironment.ordDecl = declareStdFunc("ord", new SingleFormalParameterSequence(new ConstFormalParameter(dummyI, StdEnvironment.charType, dummyPos), dummyPos), StdEnvironment.integerType);
        StdEnvironment.eofDecl = declareStdFunc("eof", new EmptyFormalParameterSequence(dummyPos), StdEnvironment.booleanType);
        StdEnvironment.eolDecl = declareStdFunc("eol", new EmptyFormalParameterSequence(dummyPos), StdEnvironment.booleanType);
        StdEnvironment.getDecl = declareStdProc("get", new SingleFormalParameterSequence(new VarFormalParameter(dummyI, StdEnvironment.charType, dummyPos), dummyPos));
        StdEnvironment.putDecl = declareStdProc("put", new SingleFormalParameterSequence(new ConstFormalParameter(dummyI, StdEnvironment.charType, dummyPos), dummyPos));
        StdEnvironment.getintDecl = declareStdProc("getint", new SingleFormalParameterSequence(new VarFormalParameter(dummyI, StdEnvironment.integerType, dummyPos), dummyPos));
        StdEnvironment.putintDecl = declareStdProc("putint", new SingleFormalParameterSequence(new ConstFormalParameter(dummyI, StdEnvironment.integerType, dummyPos), dummyPos));
        StdEnvironment.geteolDecl = declareStdProc("geteol", new EmptyFormalParameterSequence(dummyPos));
        StdEnvironment.puteolDecl = declareStdProc("puteol", new EmptyFormalParameterSequence(dummyPos));
        StdEnvironment.equalDecl = declareStdBinaryOp("=", StdEnvironment.anyType, StdEnvironment.anyType, StdEnvironment.booleanType);
        StdEnvironment.unequalDecl = declareStdBinaryOp("\\=", StdEnvironment.anyType, StdEnvironment.anyType, StdEnvironment.booleanType);

    }
}
