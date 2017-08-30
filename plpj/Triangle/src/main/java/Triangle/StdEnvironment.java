/*
 * @(#)StdEnvironment.java                        2.1 2003/10/07
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

package Triangle;

import Triangle.AbstractSyntaxTrees.*;

public final class StdEnvironment {

    //_________________________________________________________________________
    //                        These are small ASTs representing standard types

    public static TypeDenoter booleanType;
    public static TypeDenoter charType;
    public static TypeDenoter integerType;
    public static TypeDenoter anyType;
    public static TypeDenoter errorType;

    public static TypeDeclaration booleanDecl;
    public static TypeDeclaration charDecl;
    public static TypeDeclaration integerDecl;

    //_________________________________________________________________________
    //   These are small ASTs representing "declarations" of standard entities

    public static ConstDeclaration falseDecl;
    public static ConstDeclaration trueDecl;
    public static ConstDeclaration maxintDecl;

    public static UnaryOperatorDeclaration notDecl;

    public static BinaryOperatorDeclaration andDecl;
    public static BinaryOperatorDeclaration orDecl;
    public static BinaryOperatorDeclaration addDecl;
    public static BinaryOperatorDeclaration subtractDecl;
    public static BinaryOperatorDeclaration multiplyDecl;
    public static BinaryOperatorDeclaration divideDecl;
    public static BinaryOperatorDeclaration moduloDecl;
    public static BinaryOperatorDeclaration equalDecl;
    public static BinaryOperatorDeclaration unequalDecl;
    public static BinaryOperatorDeclaration lessDecl;
    public static BinaryOperatorDeclaration notlessDecl;
    public static BinaryOperatorDeclaration greaterDecl;
    public static BinaryOperatorDeclaration notgreaterDecl;

    public static ProcDeclaration getDecl;
    public static ProcDeclaration putDecl;
    public static ProcDeclaration getintDecl;
    public static ProcDeclaration putintDecl;
    public static ProcDeclaration geteolDecl;
    public static ProcDeclaration puteolDecl;

    public static FuncDeclaration chrDecl;
    public static FuncDeclaration ordDecl;
    public static FuncDeclaration eolDecl;
    public static FuncDeclaration eofDecl;
}
