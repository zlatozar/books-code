/*
 * @(#)BinaryExpression.java                        2.1 2003/10/07
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

package Triangle.AbstractSyntaxTrees;

import Triangle.SyntacticAnalyzer.SourcePosition;

public class BinaryExpression extends Expression {

    // left and right operands (keep the order)
    public Expression E1;
    public Expression E2;

    // binary operator symbol
    public Operator Op;

    public BinaryExpression(Expression e1AST, Operator oAST, Expression e2AST, SourcePosition thePosition) {
        super(thePosition);

        this.Op = oAST;
        this.E1 = e1AST;
        this.E2 = e2AST;
    }

    @Override
    public Object visit(Visitor v, Object o) {
        return v.visitBinaryExpression(this, o);
    }
}
