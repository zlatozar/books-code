/*
 * @(#)SingleRecordAggregate.java                2.1 2003/10/07
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

public class SingleRecordAggregate extends RecordAggregate {

    public Identifier I;
    public Expression E;

    public SingleRecordAggregate(Identifier iAST, Expression eAST, SourcePosition thePosition) {
        super(thePosition);

        this.I = iAST;
        this.E = eAST;
    }

    @Override
    public Object visit(Visitor v, Object o) {
        return v.visitSingleRecordAggregate(this, o);
    }
}
